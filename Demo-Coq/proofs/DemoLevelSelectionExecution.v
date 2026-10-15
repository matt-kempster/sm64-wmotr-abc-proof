From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update
  us_level_script jp_level_script.
From Demo.Proofs Require Import DemoStartExecution DemoDispatchFacts.
Import ListNotations.
Open Scope Z_scope.
Module L := us_level_update.

(** The actual course-table address expression used before the demo guard.
    Its byte offset is signed(levelNum - 1), modulo the target pointer width. *)
Definition demo_course_table_offset (level : int) : Z :=
  Ptrofs.unsigned
    (Ptrofs.add Ptrofs.zero
      (Ptrofs.mul (Ptrofs.repr 1)
        (Ptrofs.of_ints (Int.sub level Int.one)))).

Definition demo_level_selection_store_effect (before after : mem)
    (checkpoint current course : block) (level course_value : int) : Prop :=
  exists m1 m2,
    Mem.store Mint8signed before checkpoint 0 (Vint Int.zero) = Some m1 /\
    Mem.store Mint16signed m1 current 0 (Vint (Int.sign_ext 16 level)) = Some m2 /\
    Mem.store Mint16signed m2 course 0
      (Vint (Int.sign_ext 16 course_value)) = Some after.

Definition demo_returned_header_level_store_claim : Prop :=
  forall header,
    Val.load_result Mint16signed
      (Vint (Int.sign_ext 16 (Int.sign_ext 8 header))) =
    Vint (Int.sign_ext 8 header).

Theorem generated_demo_returned_header_survives_level_store :
  demo_returned_header_level_store_claim.
Proof.
  intros header. cbn [Val.load_result].
  repeat rewrite Int.sign_ext_widen by lia. reflexivity.
Qed.

(** This is the complete generated body, including its three stores and its
    early return.  The hypotheses specify an active demo and the concrete
    globals/reads touched on that path.  They do not assert retail reachability
    or relate the supplied level argument to a demo header. *)
Definition demo_level_selection_execution_claim (body : statement) : Prop :=
  forall (ge : Clight.genv) le before checkpoint current course table demo buffer ofs
      checkpoint_value course_value level,
    le ! L._levelNum = Some (Vint level) ->
    Genv.find_symbol ge L._sWarpCheckpointActive = Some checkpoint ->
    Genv.find_symbol ge L._gCurrLevelNum = Some current ->
    Genv.find_symbol ge L._gCurrCourseNum = Some course ->
    Genv.find_symbol ge L._gLevelToCourseNumTable = Some table ->
    Genv.find_symbol ge L._gCurrDemoInput = Some demo ->
    checkpoint <> current -> checkpoint <> course -> current <> course ->
    checkpoint <> table -> current <> table -> course <> table ->
    checkpoint <> demo -> current <> demo -> course <> demo ->
    Mem.load Mint8signed before checkpoint 0 = Some (Vint checkpoint_value) ->
    Mem.load Mint8signed before table (demo_course_table_offset level) =
      Some (Vint course_value) ->
    Mem.load Mptr before demo 0 = Some (Vptr buffer ofs) ->
    Mem.valid_pointer before buffer (Ptrofs.unsigned ofs) = true ->
    Mem.valid_access before Mint8signed checkpoint 0 Writable ->
    Mem.valid_access before Mint16signed current 0 Writable ->
    Mem.valid_access before Mint16signed course 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge (PTree.empty _) le before body E0 le'
        after (Out_return (Some (Vint Int.zero, tint))) /\
      Mem.load Mint16signed after current 0 =
        Some (Val.load_result Mint16signed (Vint (Int.sign_ext 16 level))) /\
      Mem.load Mptr after demo 0 = Some (Vptr buffer ofs) /\
      (forall chunk b offset permission,
        Mem.valid_access before chunk b offset permission ->
        Mem.valid_access after chunk b offset permission) /\
      demo_level_selection_store_effect before after checkpoint current course
        level course_value.

Lemma demo_valid_nonnull_pointer_comparison : forall m buffer ofs,
  Mem.valid_pointer m buffer (Ptrofs.unsigned ofs) = true ->
  cmp_ptr m Cne (Vptr buffer ofs) (Vint Int.zero) = Some (Vint Int.one).
Proof.
  intros m buffer ofs Hvalid.
  unfold cmp_ptr, Val.cmpu_bool.
  change (option_map Val.of_bool
    (if Mem.weak_valid_pointer m buffer (Ptrofs.unsigned ofs)
     then Some true else None) = Some (Vint Int.one)).
  rewrite (Mem.valid_pointer_implies _ _ _ Hvalid). reflexivity.
Qed.

(** Extract only the actual read-register / call / capture statements.  The
    command-pointer decoding prefix and interpreter continuation are outside
    this selected suffix and are not supplied by this theorem. *)
Definition demo_command_call_capture (body : statement) : statement :=
  match command_forward_capture body with
  | Some (load, call, capture) => Ssequence load (Ssequence call capture)
  | None => Sskip
  end.

Ltac dls_load :=
  first [eassumption |
    lazymatch goal with
    | |- Mem.load _ ?m _ _ = _ =>
      match goal with
      | H : Mem.store _ _ _ _ _ = Some m |- _ =>
        first
          [rewrite (Mem.load_store_same _ _ _ _ _ _ H); cbn; reflexivity
          |rewrite (Mem.load_store_other _ _ _ _ _ _ H);
           [dls_load | left; congruence]]
      end
    end].

Ltac dls_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn [set_opttemp]; repeat rewrite PTree.gsspec;
      cbn; first [eassumption | reflexivity]
  | |- eval_expr _ _ _ _ (Esizeof _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [dls_expr | demo_reduce; reflexivity]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [dls_expr | dls_expr |
        demo_reduce; first [reflexivity |
          eapply demo_valid_nonnull_pointer_comparison; eassumption]]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [dls_expr | demo_reduce; reflexivity]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue;
      [dls_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; dls_load]
             |eapply deref_loc_reference; reflexivity
             |eapply deref_loc_copy; reflexivity]]
  end
with dls_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; dls_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct;
      [dls_expr | reflexivity | eassumption | eassumption]
  end.

Ltac dls_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      first
        [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
          [dls_stmt | dls_stmt]
        |eapply exec_Sseq_2; [dls_stmt | discriminate]]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; dls_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [dls_lvalue | dls_expr | demo_reduce; reflexivity |
       eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [dls_expr | reflexivity |
       lazymatch goal with
       | |- exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ =>
           let value := eval vm_compute in b in change b with value
       end; cbn; dls_stmt]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; dls_expr
  end.

Ltac dls_proof :=
  unfold demo_level_selection_execution_claim;
  intros ge le before checkpoint current course table demo buffer ofs
    checkpoint_value course_value level Hlevel Hcheckpoint Hcurrent Hcourse
    Htable Hdemo Hcl Hcc Hlc Hct Hlt Hcot Hcd Hld Hcod
    Hcheckpoint_load Htable_load Hdemo_load Hvalid Hwcheckpoint Hwcurrent Hwcourse;
  destruct (Mem.valid_access_store before Mint8signed checkpoint 0
    (Vint Int.zero) ltac:(demo_access)) as [m1 Hs1];
  destruct (Mem.valid_access_store m1 Mint16signed current 0
    (Vint (Int.sign_ext 16 level)) ltac:(demo_access)) as [m2 Hs2];
  destruct (Mem.valid_access_store m2 Mint16signed course 0
    (Vint (Int.sign_ext 16 course_value)) ltac:(demo_access)) as [after Hs3];
  assert (Hvalid_after : Mem.valid_pointer after buffer (Ptrofs.unsigned ofs) = true)
    by (apply Mem.valid_pointer_nonempty_perm;
      eapply Mem.perm_store_1; [exact Hs3 |];
      eapply Mem.perm_store_1; [exact Hs2 |];
      eapply Mem.perm_store_1; [exact Hs1 |];
      apply Mem.valid_pointer_nonempty_perm; exact Hvalid);
  exists after; eexists; split;
  [cbn [L.f_lvl_set_current_level jp_level_update.f_lvl_set_current_level fn_body];
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dls_stmt |];
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dls_stmt |];
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dls_stmt |];
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dls_stmt |];
    eapply exec_Sseq_2; [dls_stmt | discriminate]
  |split; [dls_load | split; [dls_load | split;
    [intros; demo_access | exists m1, m2; repeat split; assumption]]]].

Theorem us_demo_level_selection_exec :
  demo_level_selection_execution_claim (fn_body L.f_lvl_set_current_level).
Proof. dls_proof. Qed.

Theorem jp_demo_level_selection_exec :
  demo_level_selection_execution_claim
    (fn_body jp_level_update.f_lvl_set_current_level).
Proof. dls_proof. Qed.

Definition demo_level_selection_execution_claim_us_jp : Prop :=
  demo_level_selection_execution_claim (fn_body L.f_lvl_set_current_level) /\
  demo_level_selection_execution_claim
    (fn_body jp_level_update.f_lvl_set_current_level).

Theorem generated_demo_level_selection_execution_us_jp :
  demo_level_selection_execution_claim_us_jp.
Proof.
  exact (conj us_demo_level_selection_exec jp_demo_level_selection_exec).
Qed.

(** The real functions have no stack variables.  This lemma constructs their
    temp-parameter entry, rather than presuming the body has been entered. *)
Definition demo_level_selection_initial_temps (f : function) (arg0 level : int)
    : temp_env :=
  PTree.set L._levelNum (Vint level)
    (PTree.set L._arg0 (Vint arg0) (create_undef_temps (fn_temps f))).

Lemma generated_demo_level_selection_function_entry :
  forall ge before arg0 level f,
    (f = L.f_lvl_set_current_level \/
     f = jp_level_update.f_lvl_set_current_level) ->
    function_entry2 ge f [Vint arg0; Vint level] before (PTree.empty _)
      (demo_level_selection_initial_temps f arg0 level) before.
Proof.
  intros ge before arg0 level f [-> | ->];
    (apply function_entry2_intro;
    [apply Coqlib.list_norepet_nil
    |apply Coqlib.list_norepet_cons; [vm_compute; intuition congruence |];
       apply Coqlib.list_norepet_cons;
       [vm_compute; intuition congruence | apply Coqlib.list_norepet_nil]
    |vm_compute; intuition congruence
    |apply alloc_variables_nil
    |reflexivity]).
Qed.

Definition demo_level_selection_call_claim (f : function) : Prop :=
  forall (ge : Clight.genv) before checkpoint current course table demo buffer ofs
      checkpoint_value course_value arg0 level,
    Genv.find_symbol ge L._sWarpCheckpointActive = Some checkpoint ->
    Genv.find_symbol ge L._gCurrLevelNum = Some current ->
    Genv.find_symbol ge L._gCurrCourseNum = Some course ->
    Genv.find_symbol ge L._gLevelToCourseNumTable = Some table ->
    Genv.find_symbol ge L._gCurrDemoInput = Some demo ->
    checkpoint <> current -> checkpoint <> course -> current <> course ->
    checkpoint <> table -> current <> table -> course <> table ->
    checkpoint <> demo -> current <> demo -> course <> demo ->
    Mem.load Mint8signed before checkpoint 0 = Some (Vint checkpoint_value) ->
    Mem.load Mint8signed before table (demo_course_table_offset level) =
      Some (Vint course_value) ->
    Mem.load Mptr before demo 0 = Some (Vptr buffer ofs) ->
    Mem.valid_pointer before buffer (Ptrofs.unsigned ofs) = true ->
    Mem.valid_access before Mint8signed checkpoint 0 Writable ->
    Mem.valid_access before Mint16signed current 0 Writable ->
    Mem.valid_access before Mint16signed course 0 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal f)
        [Vint arg0; Vint level] E0 after (Vint Int.zero) /\
      Mem.load Mint16signed after current 0 =
        Some (Val.load_result Mint16signed (Vint (Int.sign_ext 16 level))) /\
      Mem.load Mptr after demo 0 = Some (Vptr buffer ofs) /\
      (forall chunk b offset permission,
        Mem.valid_access before chunk b offset permission ->
        Mem.valid_access after chunk b offset permission) /\
      demo_level_selection_store_effect before after checkpoint current course
        level course_value.

Lemma demo_level_selection_body_to_call : forall f,
  (f = L.f_lvl_set_current_level \/
   f = jp_level_update.f_lvl_set_current_level) ->
  demo_level_selection_execution_claim (fn_body f) ->
  demo_level_selection_call_claim f.
Proof.
  intros f Hf Hbody ge before checkpoint current course table demo buffer ofs
    checkpoint_value course_value arg0 level Hcheckpoint Hcurrent Hcourse
    Htable Hdemo Hcl Hcc Hlc Hct Hlt Hcot Hcd Hld Hcod
    Hcheckpoint_load Htable_load Hdemo_load Hvalid Hwcheckpoint Hwcurrent Hwcourse.
  destruct (Hbody ge (demo_level_selection_initial_temps f arg0 level)
    before checkpoint current course table demo buffer ofs checkpoint_value
    course_value level ltac:(unfold demo_level_selection_initial_temps;
      apply PTree.gss) Hcheckpoint Hcurrent Hcourse Htable Hdemo Hcl Hcc Hlc
    Hct Hlt Hcot Hcd Hld Hcod Hcheckpoint_load Htable_load Hdemo_load Hvalid
    Hwcheckpoint Hwcurrent Hwcourse) as (after & le' & Hexec & Hlevel & Hpointer & Hperm & Hstores).
  exists after. split; [| exact (conj Hlevel (conj Hpointer (conj Hperm Hstores)))].
  eapply eval_funcall_internal.
  - exact (generated_demo_level_selection_function_entry ge before arg0 level f Hf).
  - exact Hexec.
  - destruct Hf as [-> | ->]; split; [discriminate | reflexivity | discriminate | reflexivity].
  - reflexivity.
Qed.

Definition demo_level_selection_call_claim_us_jp : Prop :=
  demo_level_selection_call_claim L.f_lvl_set_current_level /\
  demo_level_selection_call_claim jp_level_update.f_lvl_set_current_level.

Theorem generated_demo_level_selection_call_us_jp :
  demo_level_selection_call_claim_us_jp.
Proof.
  split; eapply demo_level_selection_body_to_call.
  - left. reflexivity.
  - exact us_demo_level_selection_exec.
  - right. reflexivity.
  - exact jp_demo_level_selection_exec.
Qed.

Definition demo_interpreter_level_selection_claim
    (body : statement) (f : function) : Prop :=
  forall (ge : Clight.genv) le before checkpoint current course table demo
      buffer ofs register target checkpoint_value course_value argument level,
    le ! us_level_script._func = Some (Vptr target Ptrofs.zero) ->
    le ! us_level_script._t'6 = Some (Vint argument) ->
    Genv.find_funct ge (Vptr target Ptrofs.zero) = Some (Internal f) ->
    Genv.find_symbol ge us_level_script._sRegister = Some register ->
    Genv.find_symbol ge L._sWarpCheckpointActive = Some checkpoint ->
    Genv.find_symbol ge L._gCurrLevelNum = Some current ->
    Genv.find_symbol ge L._gCurrCourseNum = Some course ->
    Genv.find_symbol ge L._gLevelToCourseNumTable = Some table ->
    Genv.find_symbol ge L._gCurrDemoInput = Some demo ->
    checkpoint <> current -> checkpoint <> course -> current <> course ->
    checkpoint <> table -> current <> table -> course <> table ->
    checkpoint <> demo -> current <> demo -> course <> demo ->
    register <> current -> register <> demo ->
    Mem.load Mint32 before register 0 = Some (Vint level) ->
    Mem.load Mint8signed before checkpoint 0 = Some (Vint checkpoint_value) ->
    Mem.load Mint8signed before table (demo_course_table_offset level) =
      Some (Vint course_value) ->
    Mem.load Mptr before demo 0 = Some (Vptr buffer ofs) ->
    Mem.valid_pointer before buffer (Ptrofs.unsigned ofs) = true ->
    Mem.valid_access before Mint32 register 0 Writable ->
    Mem.valid_access before Mint8signed checkpoint 0 Writable ->
    Mem.valid_access before Mint16signed current 0 Writable ->
    Mem.valid_access before Mint16signed course 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge (PTree.empty _) le before
        (demo_command_call_capture body) E0 le' after Out_normal /\
      Mem.load Mint32 after register 0 = Some (Vint Int.zero) /\
      Mem.load Mint16signed after current 0 =
        Some (Val.load_result Mint16signed (Vint (Int.sign_ext 16 level))) /\
      Mem.load Mptr after demo 0 = Some (Vptr buffer ofs).

Ltac demo_call_exprlist :=
  first [apply eval_Enil |
    eapply eval_Econs;
      [dls_expr | demo_reduce; reflexivity | demo_call_exprlist]].

Lemma demo_interpreter_capture_composes_with_selection : forall body f,
  (body = fn_body us_level_script.f_level_cmd_call \/
   body = fn_body jp_level_script.f_level_cmd_call) ->
  (f = L.f_lvl_set_current_level \/
   f = jp_level_update.f_lvl_set_current_level) ->
  demo_level_selection_call_claim f ->
  demo_interpreter_level_selection_claim body f.
Proof.
  intros body f Hbody Hf Hcall ge le before checkpoint current course table demo
    buffer ofs register target checkpoint_value course_value argument level
    Hfunc Harg Hfind Hregister Hcheckpoint Hcurrent Hcourse Htable Hdemo
    Hcl Hcc Hlc Hct Hlt Hcot Hcd Hld Hcod Hrl Hrd
    Hregister_load Hcheckpoint_load Htable_load Hdemo_load Hvalid
    Hwregister Hwcheckpoint Hwcurrent Hwcourse.
  destruct (Hcall ge before checkpoint current course table demo buffer ofs
    checkpoint_value course_value (Int.sign_ext 16 argument) level
    Hcheckpoint Hcurrent Hcourse Htable Hdemo Hcl Hcc Hlc Hct Hlt Hcot
    Hcd Hld Hcod Hcheckpoint_load Htable_load Hdemo_load Hvalid
    Hwcheckpoint Hwcurrent Hwcourse) as (called & Hcalled & Hlevel & Hpointer & Hperm & Hstores).
  (** Writability follows from the actual call's three-store path, whose
      permission-preservation property was proved with the body execution. *)
  assert (Hwcalled : Mem.valid_access called Mint32 register 0 Writable).
  { apply Hperm. exact Hwregister. }
  destruct (Mem.valid_access_store called Mint32 register 0 (Vint Int.zero)
    Hwcalled) as (after & Hstore).
  exists after. eexists. split.
  - destruct Hbody as [-> | ->];
      cbn [demo_command_call_capture command_forward_capture
        us_level_script.f_level_cmd_call jp_level_script.f_level_cmd_call fn_body];
      (eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dls_stmt |];
       eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
       [eapply exec_Scall;
         [reflexivity | dls_expr | demo_call_exprlist | exact Hfind |
          destruct Hf as [-> | ->]; reflexivity | exact Hcalled]
       |dls_stmt]).
  - split; [dls_load |].
    split; dls_load.
Qed.

Definition demo_interpreter_level_selection_claim_us_jp : Prop :=
  demo_interpreter_level_selection_claim
    (fn_body us_level_script.f_level_cmd_call) L.f_lvl_set_current_level /\
  demo_interpreter_level_selection_claim
    (fn_body jp_level_script.f_level_cmd_call)
    jp_level_update.f_lvl_set_current_level.

Theorem generated_demo_interpreter_level_selection_us_jp :
  demo_interpreter_level_selection_claim_us_jp.
Proof.
  destruct generated_demo_level_selection_call_us_jp as [Hus Hjp].
  split; eapply demo_interpreter_capture_composes_with_selection.
  - left. reflexivity.
  - left. reflexivity.
  - exact Hus.
  - right. reflexivity.
  - right. reflexivity.
  - exact Hjp.
Qed.

Record demo_command_layout (ge : Clight.genv) : Type := {
  demo_command_composite : composite;
  demo_command_lookup : (genv_cenv ge) ! us_level_script._LevelCommand =
    Some demo_command_composite;
  demo_command_size_offset : field_offset (genv_cenv ge) us_level_script._size
    (co_members demo_command_composite) = Errors.OK (1, Full)
}.

Definition demo_command_members : members :=
  [Member_plain us_level_script._type tuchar;
   Member_plain us_level_script._size tuchar].

Lemma generated_us_demo_command_definition :
  In (Composite us_level_script._LevelCommand Struct demo_command_members noattr)
    (prog_types us_level_script.prog).
Proof. vm_compute. repeat first [left; reflexivity | right]. Qed.

Lemma generated_jp_demo_command_definition :
  In (Composite us_level_script._LevelCommand Struct demo_command_members noattr)
    (prog_types jp_level_script.prog).
Proof. vm_compute. repeat first [left; reflexivity | right]. Qed.

Lemma generated_demo_command_layout_from_definition : forall (p : Clight.program) ge,
  In (Composite us_level_script._LevelCommand Struct demo_command_members noattr)
    (prog_types p) ->
  genv_cenv ge = prog_comp_env p ->
  exists layout : demo_command_layout ge, True.
Proof.
  intros p ge Hin Hce.
  destruct (build_composite_env_charact us_level_script._LevelCommand Struct
    demo_command_members noattr (prog_types p) (prog_comp_env p)
    (prog_comp_env_eq p) Hin) as (co & Hco & Hmembers & Hrest).
  refine (ex_intro _ {| demo_command_composite := co;
    demo_command_lookup := _; demo_command_size_offset := _ |} I).
  - rewrite Hce. exact Hco.
  - rewrite Hmembers. reflexivity.
Qed.

Definition demo_command_generated_layout_claim_us_jp : Prop :=
  (forall ge, genv_cenv ge = prog_comp_env us_level_script.prog ->
    exists layout : demo_command_layout ge, True) /\
  (forall ge, genv_cenv ge = prog_comp_env jp_level_script.prog ->
    exists layout : demo_command_layout ge, True).

Theorem generated_demo_command_layout_us_jp :
  demo_command_generated_layout_claim_us_jp.
Proof.
  split; intros ge Hce; eapply generated_demo_command_layout_from_definition.
  - exact generated_us_demo_command_definition.
  - exact Hce.
  - exact generated_jp_demo_command_definition.
  - exact Hce.
Qed.

Definition demo_command_advance (size : int) : ptrofs :=
  Ptrofs.add Ptrofs.zero
    (Ptrofs.mul (Ptrofs.repr 1)
      (Ptrofs.of_ints (Int.shl size
        (Int.shru (Int.repr 4) (Int.repr 3))))).

(** Complete generated CALL command, including function/argument decoding,
    the real level-selection call, result capture, and command advancement.
    The exact pointed-to function is resolved in ge, rather than supplied as
    an unconstrained callee-preservation assumption. *)
Definition demo_full_interpreter_level_selection_claim
    (body : statement) (f : function) : Prop :=
  forall (ge : Clight.genv) (layout : demo_command_layout ge) le before
      checkpoint current course table demo buffer ofs register target
      command_global command checkpoint_value course_value argument level size,
    Genv.find_funct ge (Vptr target Ptrofs.zero) = Some (Internal f) ->
    Genv.find_symbol ge us_level_script._sRegister = Some register ->
    Genv.find_symbol ge us_level_script._sCurrentCmd = Some command_global ->
    Genv.find_symbol ge L._sWarpCheckpointActive = Some checkpoint ->
    Genv.find_symbol ge L._gCurrLevelNum = Some current ->
    Genv.find_symbol ge L._gCurrCourseNum = Some course ->
    Genv.find_symbol ge L._gLevelToCourseNumTable = Some table ->
    Genv.find_symbol ge L._gCurrDemoInput = Some demo ->
    checkpoint <> current -> checkpoint <> course -> current <> course ->
    checkpoint <> table -> current <> table -> course <> table ->
    checkpoint <> demo -> current <> demo -> course <> demo ->
    command_global <> checkpoint -> command_global <> current ->
    command_global <> course -> command_global <> register ->
    command_global <> demo ->
    command <> checkpoint -> command <> current -> command <> course ->
    command <> register ->
    register <> current -> register <> demo ->
    Mem.load Mptr before command_global 0 = Some (Vptr command Ptrofs.zero) ->
    Mem.load Mptr before command 4 = Some (Vptr target Ptrofs.zero) ->
    Mem.load Mint16signed before command 2 = Some (Vint argument) ->
    Mem.load Mint8unsigned before command 1 = Some (Vint size) ->
    Mem.load Mint32 before register 0 = Some (Vint level) ->
    Mem.load Mint8signed before checkpoint 0 = Some (Vint checkpoint_value) ->
    Mem.load Mint8signed before table (demo_course_table_offset level) =
      Some (Vint course_value) ->
    Mem.load Mptr before demo 0 = Some (Vptr buffer ofs) ->
    Mem.valid_pointer before buffer (Ptrofs.unsigned ofs) = true ->
    Mem.valid_access before Mptr command_global 0 Writable ->
    Mem.valid_access before Mint32 register 0 Writable ->
    Mem.valid_access before Mint8signed checkpoint 0 Writable ->
    Mem.valid_access before Mint16signed current 0 Writable ->
    Mem.valid_access before Mint16signed course 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge (PTree.empty _) le before body E0 le'
        after Out_normal /\
      Mem.load Mint32 after register 0 = Some (Vint Int.zero) /\
      Mem.load Mptr after command_global 0 =
        Some (Vptr command (demo_command_advance size)) /\
      Mem.load Mint16signed after current 0 =
        Some (Val.load_result Mint16signed (Vint (Int.sign_ext 16 level))) /\
      Mem.load Mptr after demo 0 = Some (Vptr buffer ofs).

Lemma demo_full_interpreter_composes_with_selection : forall body f,
  (body = fn_body us_level_script.f_level_cmd_call \/
   body = fn_body jp_level_script.f_level_cmd_call) ->
  (f = L.f_lvl_set_current_level \/
   f = jp_level_update.f_lvl_set_current_level) ->
  demo_level_selection_call_claim f ->
  demo_full_interpreter_level_selection_claim body f.
Proof.
  intros body f Hbody Hf Hcall ge layout le before checkpoint current course
    table demo buffer ofs register target command_global command checkpoint_value
    course_value argument level size Hfind Hregister Hcommand_global
    Hcheckpoint Hcurrent Hcourse Htable Hdemo Hcl Hcc Hlc Hct Hlt Hcot
    Hcd Hld Hcod Hcgc Hcgl Hcgco Hcgr Hcgd Hcmdc Hcmdl Hcmdco Hcmdr Hrl Hrd
    Hcommand_load Htarget_load Hargument_load Hsize_load Hregister_load
    Hcheckpoint_load Htable_load Hdemo_load Hvalid Hwcommand Hwregister
    Hwcheckpoint Hwcurrent Hwcourse.
  destruct layout as [command_co Hcommand_co Hsize_offset].
  destruct (Hcall ge before checkpoint current course table demo buffer ofs
    checkpoint_value course_value (Int.sign_ext 16 argument) level
    Hcheckpoint Hcurrent Hcourse Htable Hdemo Hcl Hcc Hlc Hct Hlt Hcot
    Hcd Hld Hcod Hcheckpoint_load Htable_load Hdemo_load Hvalid
    Hwcheckpoint Hwcurrent Hwcourse)
    as (called & Hcalled & Hlevel & Hpointer & Hperm & Hstores).
  destruct Hstores as (m1 & m2 & Hs1 & Hs2 & Hs3).
  destruct (Mem.valid_access_store called Mint32 register 0 (Vint Int.zero)
    ltac:(apply Hperm; exact Hwregister)) as (captured & Hcapture).
  destruct (Mem.valid_access_store captured Mptr command_global 0
    (Vptr command (demo_command_advance size)) ltac:(demo_access))
    as (after & Hadvance).
  exists after. eexists. split.
  - destruct Hbody as [-> | ->];
      cbn [us_level_script.f_level_cmd_call jp_level_script.f_level_cmd_call fn_body];
      (eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dls_stmt |];
       eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
       [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
         [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dls_stmt |];
          eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dls_stmt |];
          eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dls_stmt |];
          eapply exec_Scall;
            [reflexivity | dls_expr | demo_call_exprlist | exact Hfind |
             destruct Hf as [-> | ->]; reflexivity | exact Hcalled]
         |dls_stmt]
       |dls_stmt]).
  - split; [dls_load |].
    split; [dls_load |]. split; dls_load.
Qed.

Definition demo_full_interpreter_level_selection_claim_us_jp : Prop :=
  demo_full_interpreter_level_selection_claim
    (fn_body us_level_script.f_level_cmd_call) L.f_lvl_set_current_level /\
  demo_full_interpreter_level_selection_claim
    (fn_body jp_level_script.f_level_cmd_call)
    jp_level_update.f_lvl_set_current_level.

Theorem generated_demo_full_interpreter_level_selection_us_jp :
  demo_full_interpreter_level_selection_claim_us_jp.
Proof.
  destruct generated_demo_level_selection_call_us_jp as [Hus Hjp].
  split; eapply demo_full_interpreter_composes_with_selection.
  - left. reflexivity.
  - left. reflexivity.
  - exact Hus.
  - right. reflexivity.
  - right. reflexivity.
  - exact Hjp.
Qed.

Lemma generated_demo_interpreter_function_entry : forall ge before f,
  (f = us_level_script.f_level_cmd_call \/
   f = jp_level_script.f_level_cmd_call) ->
  function_entry2 ge f [] before (PTree.empty _)
    (create_undef_temps (fn_temps f)) before.
Proof.
  intros ge before f [-> | ->];
    (apply function_entry2_intro;
      [apply Coqlib.list_norepet_nil
      |apply Coqlib.list_norepet_nil
      |vm_compute; intuition
      |apply alloc_variables_nil
      |reflexivity]).
Qed.

(** The body execution above can be used at its real function entry and lifted
    to a whole CALL-command funcall.  Its implicit void return and empty
    stack-freeing list are discharged here. *)
Definition demo_interpreter_function_call_bridge_claim : Prop :=
  forall ge before after f,
    (f = us_level_script.f_level_cmd_call \/
     f = jp_level_script.f_level_cmd_call) ->
    (exists le', exec_stmt function_entry2 ge (PTree.empty _)
      (create_undef_temps (fn_temps f)) before (fn_body f) E0 le' after
      Out_normal) ->
    eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef.

Theorem generated_demo_interpreter_body_to_funcall :
  demo_interpreter_function_call_bridge_claim.
Proof.
  intros ge before after f Hf (le' & Hbody).
  eapply eval_funcall_internal.
  - exact (generated_demo_interpreter_function_entry ge before f Hf).
  - exact Hbody.
  - destruct Hf as [-> | ->]; reflexivity.
  - reflexivity.
Qed.

Definition demo_complete_interpreter_level_selection_claim_us_jp : Prop :=
  demo_level_selection_call_claim_us_jp /\
  demo_full_interpreter_level_selection_claim_us_jp /\
  demo_command_generated_layout_claim_us_jp /\
  demo_interpreter_function_call_bridge_claim /\
  demo_returned_header_level_store_claim.

Theorem generated_demo_complete_interpreter_level_selection_us_jp :
  demo_complete_interpreter_level_selection_claim_us_jp.
Proof.
  exact (conj generated_demo_level_selection_call_us_jp
    (conj generated_demo_full_interpreter_level_selection_us_jp
      (conj generated_demo_command_layout_us_jp
        (conj generated_demo_interpreter_body_to_funcall
          generated_demo_returned_header_survives_level_store)))).
Qed.
