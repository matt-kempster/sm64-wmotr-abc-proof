From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Floats Globalenvs Integers Maps Memory Values.
From Demo.Generated Require Import us_title_screen jp_title_screen us_memory jp_memory.
From Demo.Proofs Require Import DemoStartExecution.
Import ListNotations.
Open Scope Z_scope.
Module TS := us_title_screen.

(** The entire title function's first-demo path. The loader remains a named
    generated callee execution premise; this is not an initialized-game trace.
    All other statements, including clear, idle tests, 799->800 countdown,
    index increment, buffer/header selection and return are executed below. *)
Record demo_title_layout (ge : Clight.genv) : Type := {
  title_install_layout : demo_install_layout ge;
  title_controller_co : composite;
  title_controller_lookup : (genv_cenv ge) ! TS._Controller = Some title_controller_co;
  title_button_offset : field_offset (genv_cenv ge) TS._buttonDown
    (co_members title_controller_co) = OK (16, Full);
  title_magnitude_offset : field_offset (genv_cenv ge) TS._stickMag
    (co_members title_controller_co) = OK (12, Full);
  title_table_co : composite;
  title_table_lookup : (genv_cenv ge) ! TS._DmaTable = Some title_table_co;
  title_count_offset : field_offset (genv_cenv ge) TS._count
    (co_members title_table_co) = OK (0, Full);
  title_table_offset : field_offset (genv_cenv ge) TS._dmaTable
    (co_members (demo_handler_composite ge title_install_layout)) = OK (0, Full)
}.

Lemma generated_whole_title_identical_us_jp :
  fn_body TS.f_run_level_id_or_demo =
  fn_body jp_title_screen.f_run_level_id_or_demo.
Proof. reflexivity. Qed.

Lemma generated_demo_loader_identical_us_jp :
  us_memory.f_load_patchable_table = jp_memory.f_load_patchable_table.
Proof. reflexivity. Qed.

Lemma title_find_funct_zero : forall (ge : Clight.genv) b fd,
  Genv.find_funct_ptr ge b = Some fd ->
  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd.
Proof. intros. cbn. exact H. Qed.

Ltac title_normalize :=
  first [match goal with
    | H : Int.eq ?x ?y = false |- _ = ?out =>
        change (Some (Val.of_bool (Int.eq x y)) = out);
        rewrite H; reflexivity
    end | demo_reduce; first [reflexivity | eassumption]].

Ltac title_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; repeat rewrite PTree.gsspec;
      cbn; first [reflexivity | eassumption]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [title_expr | title_expr | title_normalize]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [title_expr | title_normalize]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [title_expr | title_normalize]
  | |- eval_expr _ _ _ _ (Eaddrof _ _) _ =>
      eapply eval_Eaddrof; title_lvalue
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue; [title_lvalue |
        first [eapply deref_loc_value; [reflexivity | cbn; first [demo_load |
                 match goal with |- ?goal => idtac "TITLE LOAD FAILURE" goal end; fail 100]]
              | eapply deref_loc_reference; reflexivity
              | eapply deref_loc_copy; reflexivity]]
  end
with title_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ =>
      eapply eval_Ederef; title_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct;
      [title_expr | reflexivity | eassumption | eassumption]
  end.

Ltac title_arguments :=
  first [apply eval_Enil |
    eapply eval_Econs; [title_expr | title_normalize | title_arguments]].

Ltac title_reduce_statement :=
  lazymatch goal with
  | |- exec_stmt ?entry ?ge ?e ?le ?m ?s ?t ?le' ?m' ?out =>
      let reduced := eval vm_compute in s in
      change (exec_stmt entry ge e le m reduced t le' m' out)
  end.

Ltac title_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [title_stmt | title_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset ?id ?x) _ _ _ _ =>
      eapply exec_Sset; title_expr
  | |- exec_stmt _ _ _ _ _ (Sassign ?a ?b) _ _ _ _ =>
      eapply exec_Sassign;
      [title_lvalue |
       first [title_expr | match goal with |- ?g => idtac "TITLE RHS FAILED" g end; fail 100] |
       first [title_normalize | match goal with |- ?g => idtac "TITLE CAST FAILED" g end; fail 100] |
       eapply assign_loc_value; [reflexivity | cbn;
         repeat match goal with
         | H : _ ! _ = Some _ |- _ => progress rewrite H
         | H : co_sizeof _ = _ |- _ => progress rewrite H
         end; cbn;
         first [eassumption | match goal with |- ?g => idtac "TITLE STORE FAILED" g end; fail 100]]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [title_expr | cbn; reflexivity | title_reduce_statement; title_stmt]
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | title_expr | title_arguments |
       eapply title_find_funct_zero; eassumption | reflexivity | eassumption]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; title_expr
  end.

Definition demo_first_title_start_claim (body : statement) : Prop :=
  forall ge (layout : demo_title_layout ge) le before cleared counted loaded indexed
      current countdown index player controller handler table buffer save act code count header result,
    le ! TS._level = Some (Vint Int.zero) ->
    Genv.find_symbol ge TS._gCurrDemoInput = Some current ->
    Genv.find_symbol ge TS._sDemoCountdown = Some countdown ->
    Genv.find_symbol ge TS._gDemoInputListID = Some index ->
    Genv.find_symbol ge TS._gPlayer1Controller = Some player ->
    Genv.find_symbol ge TS._gDemoInputsBuf = Some handler ->
    Genv.find_symbol ge TS._gCurrSaveFileNum = Some save ->
    Genv.find_symbol ge TS._gCurrActNum = Some act ->
    Genv.find_symbol ge TS._load_patchable_table = Some code ->
    Genv.find_funct_ptr ge code = Some (Internal us_memory.f_load_patchable_table) ->
    current <> player -> current <> controller -> current <> countdown -> current <> index ->
    countdown <> index ->
    index <> handler -> index <> table -> index <> buffer -> index <> current ->
    handler <> current -> buffer <> current ->
    current <> save -> current <> act -> save <> act ->
    Mem.store Mptr before current 0 (Vint Int.zero) = Some cleared ->
    Mem.load Mptr cleared player 0 = Some (Vptr controller Ptrofs.zero) ->
    Mem.load Mint16unsigned cleared controller 16 = Some (Vint Int.zero) ->
    Mem.load Mfloat32 cleared controller 12 = Some (Vsingle Float32.zero) ->
    Mem.load Mint16unsigned cleared countdown 0 = Some (Vint (Int.repr 799)) ->
    Mem.load Mint16unsigned counted index 0 = Some (Vint Int.zero) ->
    Mem.store Mint16unsigned cleared countdown 0 (Vint (Int.repr 800)) = Some counted ->
    eval_funcall function_entry2 ge counted (Internal us_memory.f_load_patchable_table)
      [Vptr handler Ptrofs.zero; Vint Int.zero] E0 loaded (Vint result) ->
    Mem.load Mint16unsigned loaded index 0 = Some (Vint Int.zero) ->
    Mem.load Mptr loaded handler 0 = Some (Vptr table Ptrofs.zero) ->
    Mem.load Mint32 loaded table 0 = Some (Vint count) ->
    Int.eq Int.one count = false ->
    Mem.store Mint16unsigned loaded index 0 (Vint Int.one) = Some indexed ->
    Mem.load Mptr loaded handler 8 = Some (Vptr buffer Ptrofs.zero) ->
    Mem.load Mint8unsigned loaded buffer 0 = Some (Vint header) ->
    Mem.valid_access indexed Mptr current 0 Writable ->
    Mem.valid_access indexed Mint16signed save 0 Writable ->
    Mem.valid_access indexed Mint16signed act 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge (PTree.empty _) le before body E0 le' after
        (Out_return (Some (Vint (Int.sign_ext 8 header), tint))) /\
      Mem.load Mptr after current 0 = Some (Vptr buffer (Ptrofs.repr 4)).

Theorem generated_first_title_start_executes :
  demo_first_title_start_claim (fn_body TS.f_run_level_id_or_demo).
Proof.
  unfold demo_first_title_start_claim.
  intros ge layout le before cleared counted loaded indexed
    current countdown index player controller handler table buffer save act code count header result
    Hlevel Hcurrent Hcountdown Hindex Hplayer Hhandler Hsave Hact Hcode Hfd
    Hcp Hcc Hct Hci Hti Hih Hit Hib Hic Hhc Hbc Hcs Hca Hsa
    Hclear Hplayerload Hbuttons Hmagnitude Htimer Hindexcounted Hcountstore Hloader
    Hindexloaded Htable Hcount Hnotwrap Hindexstore Htarget Hheader Hwcurrent Hwsave Hwact.
  destruct layout as [install controller_co Hcontroller Hbuttonoffset Hmagoffset
    table_co Htableco Hcountoffset Htableoffset].
  destruct install as [handler_co input_co Hhandlerco Hinputco Htargetoffset Htimeroffset Hinputsize].
  let demo_id := eval vm_compute in TS._DemoInput in
  change ((genv_cenv ge) ! demo_id = Some input_co) in Hinputco.
  destruct (Mem.valid_access_store indexed Mptr current 0
    (Vptr buffer (Ptrofs.repr 4)) Hwcurrent) as [installed Hinstall].
  destruct (Mem.valid_access_store installed Mint16signed save 0
    (Vint Int.one) ltac:(demo_access)) as [saved Hsaved].
  destruct (Mem.valid_access_store saved Mint16signed act 0
    (Vint Int.one) ltac:(demo_access)) as [after Hacted].
  exists after. eexists. split.
  - cbn [TS.f_run_level_id_or_demo fn_body]. title_stmt.
  - demo_load.
Qed.

Definition demo_first_title_start_claim_us_jp : Prop :=
  us_memory.f_load_patchable_table = jp_memory.f_load_patchable_table /\
  demo_first_title_start_claim (fn_body TS.f_run_level_id_or_demo) /\
  demo_first_title_start_claim (fn_body jp_title_screen.f_run_level_id_or_demo).

Theorem generated_first_title_start_us_jp : demo_first_title_start_claim_us_jp.
Proof.
  split; [exact generated_demo_loader_identical_us_jp |].
  split; exact generated_first_title_start_executes.
Qed.
