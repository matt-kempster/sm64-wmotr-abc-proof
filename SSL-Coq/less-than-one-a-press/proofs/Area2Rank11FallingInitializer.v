(** The real airborne initializer for ordinary non-jumping pole exits.
    This constructs the entire selected function body from a normal
    unsquished, zero-depth entry.  The two stores are peakHeight and flags;
    Mario's position, horizontal speed and all velocities are framed. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Events Floats Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  Area2Rank11PoleExitSplit Area2Rank11BodyResolution Area2Rank11LivePoleExit
  GameTypes SelectedClightTarget.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition rank11_initializer_tail_statement : statement :=
  Ssequence
    (Ssequence (Sset R11MU._t'7 rank11_mario_y_expression)
      (Sassign (rank11_mario_field_expression R11MU._peakHeight tfloat)
        (Etempvar R11MU._t'7 tfloat)))
    (Ssequence
      (Ssequence
        (Sset R11MU._t'6 (rank11_mario_field_expression R11MU._flags tuint))
        (Sassign (rank11_mario_field_expression R11MU._flags tuint)
          (Ebinop Oor (Etempvar R11MU._t'6 tuint)
            (Econst_int (Int.repr 256) tint) tuint)))
      (Sreturn (Some (Etempvar R11MU._action tuint)))).

Lemma rank11_initializer_tail_is_generated : forall version,
  rank11_airborne_tail version = rank11_initializer_tail_statement.
Proof. intros []; reflexivity. Qed.

Definition rank11_initializer_suffix version :=
  Ssequence (Sswitch (Etempvar R11MU._action tuint)
    (rank11_airborne_switch_cases version)) (rank11_airborne_tail version).

Definition rank11_tail_locals locals y flags :=
  PTree.set R11MU._t'6 (Vint flags)
    (PTree.set R11MU._t'7 (Vsingle y) locals).

Definition Rank11OutsideInitializerStores
    (mario : block) (chunk : memory_chunk) (read_block : block) (offset : Z) : Prop :=
  (read_block <> mario \/ offset + size_chunk chunk <= 4 \/ 8 <= offset) /\
  (read_block <> mario \/ offset + size_chunk chunk <= 188 \/ 192 <= offset).

Theorem rank11_falling_suffix_executes_two_stores :
  forall version exit environment locals memory mario y flags,
    let ge := Clight.globalenv (selected_clight_target version) in
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    locals ! R11MU._action = Some (Vint (rank11_falling_action exit)) ->
    Mem.load Mfloat32 memory mario 64 = Some (Vsingle y) ->
    Mem.load Mint32 memory mario 4 = Some (Vint flags) ->
    Mem.valid_access memory Mfloat32 mario 188 Writable ->
    Mem.valid_access memory Mint32 mario 4 Writable ->
    exists middle after,
      Mem.store Mfloat32 memory mario 188 (Vsingle y) = Some middle /\
      Mem.store Mint32 middle mario 4 (Vint (Int.or flags (Int.repr 256))) =
        Some after /\
      ClightBigstep.Clight2.exec_stmt ge environment locals memory
        (rank11_initializer_suffix version) E0
        (rank11_tail_locals locals y flags) after
        (Out_return (Some (Vint (rank11_falling_action exit), tuint))) /\
      (forall chunk read_block offset,
        Rank11OutsideInitializerStores mario chunk read_block offset ->
        Mem.load chunk after read_block offset =
          Mem.load chunk memory read_block offset).
Proof.
  intros version exit environment locals memory mario y flags ge
    Hm Haction Hy Hflags Hpeak_access Hflags_access.
  destruct (Mem.valid_access_store memory Mfloat32 mario 188 (Vsingle y)
    Hpeak_access) as [middle Hpeak].
  assert (Hflags_middle : Mem.load Mint32 middle mario 4 = Some (Vint flags)).
  { rewrite <- Hflags. eapply Mem.load_store_other; [exact Hpeak |].
    right. left. cbn. lia. }
  assert (Hflags_access_middle : Mem.valid_access middle Mint32 mario 4 Writable).
  { eapply Mem.store_valid_access_1; eauto. }
  destruct (Mem.valid_access_store middle Mint32 mario 4
    (Vint (Int.or flags (Int.repr 256))) Hflags_access_middle)
    as [after Hflagstore].
  exists middle, after. split; [exact Hpeak |].
  split; [exact Hflagstore |]. split.
  - unfold rank11_initializer_suffix.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sswitch with (v := Vint (rank11_falling_action exit))
        (n := Int.unsigned (rank11_falling_action exit)) (out := Out_normal).
      * apply eval_Etempvar. exact Haction.
      * reflexivity.
      * rewrite rank11_falling_exits_select_no_jump_initializer. constructor.
    + rewrite rank11_initializer_tail_is_generated.
      unfold rank11_initializer_tail_statement, rank11_tail_locals.
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- apply exec_Sset. eapply rank11_mario_y_read; eauto.
        -- eapply exec_Sassign with (loc := mario) (ofs := Ptrofs.repr 188)
             (bf := Full) (v2 := Vsingle y) (v := Vsingle y).
           ++ eapply rank11_mario_field_lvalue with (offset := 188).
              ** rewrite PTree.gso by discriminate. exact Hm.
              ** cbn; auto 12.
           ++ apply eval_Etempvar. apply PTree.gss.
           ++ reflexivity.
           ++ eapply assign_loc_value with (chunk := Mfloat32);
                [reflexivity | exact Hpeak].
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ apply exec_Sset. eapply rank11_mario_field_read
                with (offset := 4) (chunk := Mint32).
              ** rewrite PTree.gso by discriminate. exact Hm.
              ** cbn; auto 12.
              ** reflexivity.
              ** reflexivity.
              ** exact Hflags_middle.
           ++ eapply exec_Sassign with (loc := mario) (ofs := Ptrofs.repr 4)
                (bf := Full) (v2 := Vint (Int.or flags (Int.repr 256)))
                (v := Vint (Int.or flags (Int.repr 256))).
              ** eapply rank11_mario_field_lvalue with (offset := 4).
                 --- repeat rewrite PTree.gso by discriminate. exact Hm.
                 --- cbn; auto 12.
              ** eapply eval_Ebinop.
                 --- apply eval_Etempvar. apply PTree.gss.
                 --- constructor.
                 --- reflexivity.
              ** reflexivity.
              ** eapply assign_loc_value with (chunk := Mint32);
                   [reflexivity | exact Hflagstore].
        -- apply exec_Sreturn_some. apply eval_Etempvar.
           repeat rewrite PTree.gso by discriminate. exact Haction.
  - intros chunk read_block offset [Houtside_flags Houtside_peak].
    transitivity (Mem.load chunk middle read_block offset).
    + eapply Mem.load_store_other; [exact Hflagstore | exact Houtside_flags].
    + eapply Mem.load_store_other; [exact Hpeak | exact Houtside_peak].
Qed.

Definition rank11_zero_depth_prefix_locals locals :=
  PTree.set R11MU._t'2 (Vint Int.zero)
    (PTree.set R11MU._t'1 (Vint Int.zero)
      (PTree.set R11MU._t'23 (Vsingle Float32.zero)
        (PTree.set R11MU._t'22 (Vint Int.zero) locals))).

(** Unsquished, zero-depth entry is the ordinary case, but remains an actual
    memory premise, not an invented consequence of the no-A input history. *)
Theorem rank11_zero_depth_initializer_prefix_executes :
  forall version environment locals memory mario,
    let ge := Clight.globalenv (selected_clight_target version) in
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mint8unsigned memory mario 180 = Some (Vint Int.zero) ->
    Mem.load Mfloat32 memory mario 192 = Some (Vsingle Float32.zero) ->
    ClightBigstep.Clight2.exec_stmt ge environment locals memory
      (rank11_airborne_prefix version) E0
      (rank11_zero_depth_prefix_locals locals) memory Out_normal.
Proof.
  intros version environment locals memory mario ge Hm Hsquish Hdepth.
  assert (Hprefix : rank11_airborne_prefix version = rank11_airborne_prefix VersionUS)
    by (destruct version; reflexivity).
  rewrite Hprefix. unfold rank11_airborne_prefix, rank11_airborne_body.
  cbn [fn_body]. unfold rank11_zero_depth_prefix_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply rank11_mario_field_read
          with (offset := 180) (chunk := Mint8unsigned); eauto;
          try reflexivity; cbn; auto 12.
      * eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
        -- eapply eval_Ebinop; [apply eval_Etempvar; apply PTree.gss |
             constructor | reflexivity].
        -- reflexivity.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ apply exec_Sset. eapply rank11_mario_field_read
                with (offset := 192) (chunk := Mfloat32).
              ** rewrite PTree.gso by discriminate. exact Hm.
              ** cbn; auto 12.
              ** reflexivity.
              ** reflexivity.
              ** exact Hdepth.
           ++ apply exec_Sset. eapply eval_Ecast with (v1 := Vint Int.zero).
              ** eapply eval_Ebinop; [apply eval_Etempvar; apply PTree.gss |
                   constructor | reflexivity].
              ** reflexivity.
    + eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
      * apply eval_Etempvar. apply PTree.gss.
      * reflexivity.
      * apply exec_Sset. constructor.
  - eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
    + apply eval_Etempvar. apply PTree.gss.
    + reflexivity.
    + constructor.
Qed.

Theorem rank11_complete_falling_initializer_preserves_kinematics :
  forall version exit environment locals memory mario y flags,
    let ge := Clight.globalenv (selected_clight_target version) in
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    locals ! R11MU._action = Some (Vint (rank11_falling_action exit)) ->
    Mem.load Mint8unsigned memory mario 180 = Some (Vint Int.zero) ->
    Mem.load Mfloat32 memory mario 192 = Some (Vsingle Float32.zero) ->
    Mem.load Mfloat32 memory mario 64 = Some (Vsingle y) ->
    Mem.load Mint32 memory mario 4 = Some (Vint flags) ->
    Mem.valid_access memory Mfloat32 mario 188 Writable ->
    Mem.valid_access memory Mint32 mario 4 Writable ->
    exists after,
      ClightBigstep.Clight2.exec_stmt ge environment locals memory
        (fn_body (rank11_airborne_body version)) E0
        (rank11_tail_locals (rank11_zero_depth_prefix_locals locals) y flags) after
        (Out_return (Some (Vint (rank11_falling_action exit), tuint))) /\
      (forall offset, In offset [60; 64; 68; 72; 76; 80; 84] ->
        Mem.load Mfloat32 after mario offset = Mem.load Mfloat32 memory mario offset).
Proof.
  intros version exit environment locals memory mario y flags ge
    Hm Haction Hsquish Hdepth Hy Hflags Hpeak_access Hflags_access.
  pose proof (rank11_zero_depth_initializer_prefix_executes version environment
    locals memory mario Hm Hsquish Hdepth) as Hprefix.
  assert (Hm' : (rank11_zero_depth_prefix_locals locals) ! R11MU._m =
    Some (Vptr mario Ptrofs.zero)).
  { unfold rank11_zero_depth_prefix_locals.
    repeat rewrite PTree.gso by discriminate. exact Hm. }
  assert (Haction' : (rank11_zero_depth_prefix_locals locals) ! R11MU._action =
    Some (Vint (rank11_falling_action exit))).
  { unfold rank11_zero_depth_prefix_locals.
    repeat rewrite PTree.gso by discriminate. exact Haction. }
  destruct (rank11_falling_suffix_executes_two_stores version exit environment
    (rank11_zero_depth_prefix_locals locals) memory mario y flags
    Hm' Haction' Hy Hflags Hpeak_access Hflags_access)
    as (middle & after & Hpeak & Hflagstore & Hsuffix & Hframe).
  exists after. split.
  - rewrite rank11_airborne_body_decomposition.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); eauto.
  - intros offset Hin. apply Hframe.
    unfold Rank11OutsideInitializerStores.
    cbn in Hin. repeat destruct Hin as [Hin | Hin]; try contradiction;
      subst offset; cbn; split; right; intuition lia.
Qed.

Definition rank11_initializer_entry_locals version mario exit : temp_env :=
  PTree.set R11MU._actionArg (Vint Int.zero)
    (PTree.set R11MU._action (Vint (rank11_falling_action exit))
      (PTree.set R11MU._m (Vptr mario Ptrofs.zero)
        (create_undef_temps (fn_temps (rank11_airborne_body version))))).

Lemma rank11_initializer_real_function_entry : forall version mario exit memory,
  function_entry2 (Clight.globalenv (selected_clight_target version))
    (rank11_airborne_body version)
    [Vptr mario Ptrofs.zero; Vint (rank11_falling_action exit); Vint Int.zero]
    memory empty_env (rank11_initializer_entry_locals version mario exit) memory.
Proof.
  intros version mario exit memory. constructor.
  - destruct version; constructor.
  - assert (Hnames : list_norepet [R11MU._m; R11MU._action; R11MU._actionArg]).
    { constructor; [vm_compute; intuition discriminate |].
      constructor; [vm_compute; intuition discriminate |].
      constructor; [cbn; tauto | constructor]. }
    destruct version; exact Hnames.
  - unfold list_disjoint. intros parameter temporary Hparameter Htemporary Hequal.
    subst temporary. destruct version; vm_compute in Hparameter, Htemporary;
      intuition congruence.
  - destruct version; constructor.
  - destruct version; reflexivity.
Qed.

Definition Rank11FallingCallClosure : Prop :=
  forall version exit memory mario y flags continuation,
    let ge := Clight.globalenv (selected_clight_target version) in
    Mem.load Mint8unsigned memory mario 180 = Some (Vint Int.zero) ->
    Mem.load Mfloat32 memory mario 192 = Some (Vsingle Float32.zero) ->
    Mem.load Mfloat32 memory mario 64 = Some (Vsingle y) ->
    Mem.load Mint32 memory mario 4 = Some (Vint flags) ->
    Mem.valid_access memory Mfloat32 mario 188 Writable ->
    Mem.valid_access memory Mint32 mario 4 Writable ->
    is_call_cont continuation ->
    exists function_block after,
      Genv.find_symbol ge R11MU._set_mario_action_airborne = Some function_block /\
      Genv.find_funct_ptr ge function_block =
        Some (Internal (rank11_airborne_body version)) /\
      @Smallstep.star _ _ Clight.step2 ge
        (Callstate (Internal (rank11_airborne_body version))
          [Vptr mario Ptrofs.zero; Vint (rank11_falling_action exit); Vint Int.zero]
          continuation memory) E0
        (Returnstate (Vint (rank11_falling_action exit)) continuation after) /\
      (forall offset, In offset [60; 64; 68; 72; 76; 80; 84] ->
        Mem.load Mfloat32 after mario offset = Mem.load Mfloat32 memory mario offset).

(** This now starts at a real call, allocates/binds its actual parameters,
    follows one body execution, and returns through the same continuation.
    It is neither an assumed endpoint nor an IDO/MIPS simulation. *)
Theorem rank11_selected_falling_call_safely_returns : Rank11FallingCallClosure.
Proof.
  intros version exit memory mario y flags continuation ge
    Hsquish Hdepth Hy Hflags Hpeak_access Hflags_access Hcontinuation.
  assert (Hm : (rank11_initializer_entry_locals version mario exit) ! R11MU._m =
    Some (Vptr mario Ptrofs.zero)).
  { unfold rank11_initializer_entry_locals. rank11_temp. }
  assert (Haction : (rank11_initializer_entry_locals version mario exit) !
    R11MU._action = Some (Vint (rank11_falling_action exit))).
  { unfold rank11_initializer_entry_locals. rank11_temp. }
  destruct (rank11_complete_falling_initializer_preserves_kinematics version exit
    empty_env (rank11_initializer_entry_locals version mario exit) memory mario
    y flags Hm Haction Hsquish Hdepth Hy Hflags Hpeak_access Hflags_access)
    as (after & Hexecute & Hframe).
  assert (Hcall : ClightBigstep.Clight2.eval_funcall ge memory
    (Internal (rank11_airborne_body version))
    [Vptr mario Ptrofs.zero; Vint (rank11_falling_action exit); Vint Int.zero]
    E0 after (Vint (rank11_falling_action exit))).
  { eapply eval_funcall_internal.
    - apply rank11_initializer_real_function_entry.
    - exact Hexecute.
    - destruct version; cbn [rank11_airborne_body fn_return outcome_result_value];
        split; solve [discriminate | reflexivity].
    - reflexivity. }
  destruct (rank11_selected_native_body_resolves version R11AirborneInitializer)
    as (function_block & Hsymbol & Hbody).
  exists function_block, after. split; [exact Hsymbol |].
  split; [exact Hbody |]. split; [| exact Hframe].
  eapply (ClightBigstep.eval_funcall_steps Clight.function_entry2
    (selected_clight_target version)); eauto.
Qed.
