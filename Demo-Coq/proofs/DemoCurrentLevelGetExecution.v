From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_script jp_level_script
  us_level_scripts jp_level_scripts.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution
  DemoConditionalDispatchExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module G := us_level_script.

(** GET(VAR_CURR_LEVEL_NUM) in the authentic dispatch table. The selected
    function is executed in full, including the register store and command
    advance. The command bytes and starting pointer remain explicit reads. *)
Ltac level_get_load :=
 first [reflexivity | eassumption |
   lazymatch goal with |- Mem.load _ ?memory _ _ = _ =>
     match goal with H : Mem.store _ _ _ _ _ = Some memory |- _ =>
       first [rewrite (Mem.load_store_same _ _ _ _ _ _ H); cbn; reflexivity |
         rewrite (Mem.load_store_other _ _ _ _ _ _ H) by (left; congruence);
         level_get_load]
     end
   end].

Ltac level_get_expr :=
 lazymatch goal with
 | |- eval_expr _ _ _ _ (Econst_int _ _) _ => eapply eval_Econst_int
 | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
   eapply eval_Etempvar; repeat rewrite PTree.gsspec; cbn; reflexivity
 | |- eval_expr _ _ _ _ (Esizeof _ _) _ => eapply eval_Esizeof
 | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
   eapply eval_Ebinop; [level_get_expr | level_get_expr | demo_reduce; reflexivity]
 | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
   eapply eval_Eunop; [level_get_expr | demo_reduce; reflexivity]
 | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
   eapply eval_Ecast; [level_get_expr | demo_reduce; reflexivity]
 | |- eval_expr _ _ _ _ _ _ => eapply eval_Elvalue;
   [level_get_lvalue |
     first [eapply deref_loc_value; [reflexivity | cbn; level_get_load] |
       eapply deref_loc_reference; reflexivity |
       eapply deref_loc_copy; reflexivity]]
 end
with level_get_lvalue :=
 lazymatch goal with
 | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
   eapply eval_Evar_global; [reflexivity | eassumption]
 | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ =>
   eapply eval_Ederef; level_get_expr
 | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
   eapply eval_Efield_struct;
     [level_get_expr | reflexivity | eassumption | eassumption]
 end.

Ltac level_get_stmt :=
 lazymatch goal with
 | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => eapply exec_Sskip
 | |- exec_stmt _ _ _ _ _ Sbreak _ _ _ _ => eapply exec_Sbreak
 | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ Out_break =>
   first [eapply exec_Sseq_2; [level_get_stmt | discriminate] |
     eapply exec_Sseq_1 with (t1:=E0) (t2:=E0); [level_get_stmt | level_get_stmt]]
 | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
   eapply exec_Sseq_1 with (t1:=E0) (t2:=E0); [level_get_stmt | level_get_stmt]
 | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
   eapply exec_Sset; level_get_expr
 | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
   eapply exec_Sassign;
   [level_get_lvalue | level_get_expr | demo_reduce; reflexivity |
     eapply assign_loc_value; [reflexivity | cbn; eassumption]]
 | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
   eapply exec_Sifthenelse; [level_get_expr | reflexivity |
     lazymatch goal with
     | |- exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ =>
       let decision := eval vm_compute in b in change b with decision
     end; cbn; level_get_stmt]
 | |- exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ =>
   eapply exec_Sswitch with (n:=3) (out:=Out_break);
     [level_get_expr | reflexivity | cbn; level_get_stmt]
 end.

Definition demo_current_level_get_body_claim (body : statement) : Prop :=
 forall (ge : Clight.genv) le before command_global command base register current
     command_co level,
  Genv.find_symbol ge G._sCurrentCmd = Some command_global ->
  Genv.find_symbol ge G._sRegister = Some register ->
  Genv.find_symbol ge G._gCurrLevelNum = Some current ->
  (genv_cenv ge) ! G._LevelCommand = Some command_co ->
  field_offset (genv_cenv ge) G._size (co_members command_co) = OK (1,Full) ->
  register <> command_global -> register <> command -> register <> current ->
  command_global <> current ->
  Mem.load Mptr before command_global 0 = Some (Vptr command base) ->
  Mem.load Mint8unsigned before command
    (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 1))) = Some (Vint (Int.repr 4)) ->
  Mem.load Mint8unsigned before command
    (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 2))) = Some (Vint (Int.repr 1)) ->
  Mem.load Mint8unsigned before command
    (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 3))) = Some (Vint (Int.repr 3)) ->
  Mem.load Mint16signed before current 0 = Some (Vint level) ->
  Mem.valid_access before Mint32 register 0 Writable ->
  Mem.valid_access before Mptr command_global 0 Writable ->
  exists after le',
   exec_stmt function_entry2 ge empty_env le before body E0 le' after Out_normal /\
   Mem.load Mint32 after register 0 = Some (Vint level) /\
   Mem.load Mptr after command_global 0 =
     Some (Vptr command (Ptrofs.add base (Ptrofs.repr 4))) /\
   Mem.load Mint16signed after current 0 = Some (Vint level) /\
   (forall chunk b offset, b <> register -> b <> command_global ->
     Mem.load chunk after b offset = Mem.load chunk before b offset) /\
   (forall chunk b offset permission, Mem.valid_access before chunk b offset permission ->
     Mem.valid_access after chunk b offset permission).

Theorem generated_current_level_get_body_executes :
 demo_current_level_get_body_claim (fn_body G.f_level_cmd_get_or_set_var).
Proof.
 intros ge le before command_global command base register current command_co level
   Hcmd Hreg Hcurrent Hco Hsize Hrc Hrb Hrl Hcl Hpointer Hbytes Hop Hvar Hlevel Hwr Hwc.
 destruct (Mem.valid_access_store before Mint32 register 0 (Vint level) Hwr)
   as (middle & Hstore_register).
 destruct (Mem.valid_access_store middle Mptr command_global 0
   (Vptr command (Ptrofs.add base (Ptrofs.repr 4)))
   ltac:(eapply Mem.store_valid_access_1; eassumption)) as (after & Hstore_command).
 exists after; eexists; split.
 - cbn [G.f_level_cmd_get_or_set_var fn_body]. level_get_stmt.
 - split; [level_get_load |]. split; [level_get_load |].
   split; [level_get_load |]. split.
   + intros chunk b offset Hbr Hbc. level_get_load.
   + intros chunk b offset permission Haccess.
     eapply Mem.store_valid_access_1; [exact Hstore_command |].
     eapply Mem.store_valid_access_1; eassumption.
Qed.

Lemma generated_current_level_get_function_entry : forall ge before f,
 (f = G.f_level_cmd_get_or_set_var \/ f = jp_level_script.f_level_cmd_get_or_set_var) ->
 function_entry2 ge f [] before empty_env (create_undef_temps (fn_temps f)) before.
Proof.
 intros ge before f [-> | ->]; (apply function_entry2_intro;
 [apply Coqlib.list_norepet_nil | apply Coqlib.list_norepet_nil |
  unfold list_disjoint; cbn; tauto | constructor | reflexivity]).
Qed.

Definition demo_current_level_get_call_claim : Prop :=
 forall (us : bool) (ge : Clight.genv) before command_global command base register current
     command_co level,
  Genv.find_symbol ge G._sCurrentCmd = Some command_global ->
  Genv.find_symbol ge G._sRegister = Some register ->
  Genv.find_symbol ge G._gCurrLevelNum = Some current ->
  (genv_cenv ge) ! G._LevelCommand = Some command_co ->
  field_offset (genv_cenv ge) G._size (co_members command_co) = OK (1,Full) ->
  register <> command_global -> register <> command -> register <> current ->
  command_global <> current ->
  Mem.load Mptr before command_global 0 = Some (Vptr command base) ->
  Mem.load Mint8unsigned before command
    (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 1))) = Some (Vint (Int.repr 4)) ->
  Mem.load Mint8unsigned before command
    (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 2))) = Some (Vint (Int.repr 1)) ->
  Mem.load Mint8unsigned before command
    (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 3))) = Some (Vint (Int.repr 3)) ->
  Mem.load Mint16signed before current 0 = Some (Vint level) ->
  Mem.valid_access before Mint32 register 0 Writable ->
  Mem.valid_access before Mptr command_global 0 Writable ->
  exists after,
   eval_funcall function_entry2 ge before
     (Internal (if us then G.f_level_cmd_get_or_set_var
       else jp_level_script.f_level_cmd_get_or_set_var)) [] E0 after Vundef /\
   Mem.load Mint32 after register 0 = Some (Vint level) /\
   Mem.load Mptr after command_global 0 =
     Some (Vptr command (Ptrofs.add base (Ptrofs.repr 4))) /\
   Mem.load Mint16signed after current 0 = Some (Vint level) /\
   (forall chunk b offset, b <> register -> b <> command_global ->
     Mem.load chunk after b offset = Mem.load chunk before b offset) /\
   (forall chunk b offset permission, Mem.valid_access before chunk b offset permission ->
     Mem.valid_access after chunk b offset permission).

Theorem generated_current_level_get_call_executes : demo_current_level_get_call_claim.
Proof.
 intros us ge before command_global command base register current command_co level
   Hcmd Hreg Hcurrent Hco Hsize Hrc Hrb Hrl Hcl Hpointer Hbytes Hop Hvar Hlevel Hwr Hwc.
 destruct (generated_current_level_get_body_executes ge
   (create_undef_temps (fn_temps G.f_level_cmd_get_or_set_var)) before
   command_global command base register current command_co level Hcmd Hreg Hcurrent
   Hco Hsize Hrc Hrb Hrl Hcl Hpointer Hbytes Hop Hvar Hlevel Hwr Hwc)
   as (after & le' & Hbody & Hresult).
 exists after; split; [| exact Hresult].
 assert (Hselected : (if us then G.f_level_cmd_get_or_set_var
   else jp_level_script.f_level_cmd_get_or_set_var) = G.f_level_cmd_get_or_set_var)
   by (destruct us; reflexivity).
 rewrite Hselected.
 eapply eval_funcall_internal with (e:=empty_env)
   (le1:=create_undef_temps (fn_temps G.f_level_cmd_get_or_set_var))
   (m1:=before) (m2:=after) (out:=Out_normal).
 - apply generated_current_level_get_function_entry. left; reflexivity.
 - exact Hbody.
 - reflexivity.
 - reflexivity.
Qed.

Definition demo_current_level_get_dispatch_syntax_claim_us_jp : Prop :=
 nth_error (gvar_init G.v_LevelScriptJumpTable) 60 =
   Some (Init_addrof G._level_cmd_get_or_set_var Ptrofs.zero) /\
 nth_error (gvar_init jp_level_script.v_LevelScriptJumpTable) 60 =
   Some (Init_addrof jp_level_script._level_cmd_get_or_set_var Ptrofs.zero) /\
 firstn 1 (gvar_init us_level_scripts.v_script_exec_level_table) =
   [Init_int32 (Int.repr 1006895363)] /\
 firstn 1 (gvar_init jp_level_scripts.v_script_exec_level_table) =
   [Init_int32 (Int.repr 1006895363)].

Theorem generated_current_level_get_dispatch_syntax_us_jp :
 demo_current_level_get_dispatch_syntax_claim_us_jp.
Proof. vm_compute; repeat split; reflexivity. Qed.

Definition demo_current_level_get_claim_us_jp : Prop :=
 demo_current_level_get_dispatch_syntax_claim_us_jp /\
 G.f_level_cmd_get_or_set_var = jp_level_script.f_level_cmd_get_or_set_var /\
 demo_current_level_get_body_claim (fn_body G.f_level_cmd_get_or_set_var) /\
 demo_current_level_get_body_claim (fn_body jp_level_script.f_level_cmd_get_or_set_var) /\
 demo_current_level_get_call_claim.

Theorem generated_current_level_get_us_jp : demo_current_level_get_claim_us_jp.
Proof.
 split; [exact generated_current_level_get_dispatch_syntax_us_jp |].
 split; [reflexivity |]. split; [exact generated_current_level_get_body_executes |].
 split; [exact generated_current_level_get_body_executes |
   exact generated_current_level_get_call_executes].
Qed.
