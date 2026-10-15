From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop Ctypes
  Errors Events Floats Globalenvs Integers Maps Memdata Memory Smallstep Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution
  DemoPlaybackExecution DemoPlaybackAdvanceExecution DemoControllerInputExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

(** A semantic store-permission lemma, not a model of the input consumer.
    The eventual caller checks this syntax predicate on its actual generated
    body.  Unsupported command classes deliberately reject. *)
Fixpoint stores_only_statement (s : statement) : bool :=
  match s with
  | Scall _ _ _ | Sbuiltin _ _ _ _ | Sswitch _ _ | Slabel _ _ => false
  | Ssequence a b | Sloop a b => stores_only_statement a && stores_only_statement b
  | Sifthenelse _ a b => stores_only_statement a && stores_only_statement b
  | _ => true
  end.

Lemma assign_location_preserves_permissions :
  forall ge ty before b ofs bf value after target offset kind permission,
    assign_loc ge ty before b ofs bf value after ->
    Mem.perm before target offset kind permission ->
    Mem.perm after target offset kind permission.
Proof.
  intros ge ty before b ofs bf value after target offset kind permission Hassign Hperm.
  inversion Hassign; subst.
  - eapply Mem.perm_store_1; eassumption.
  - eapply Mem.perm_storebytes_1; eassumption.
  - match goal with H : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ =>
      inversion H; subst end.
    eapply Mem.perm_store_1; eassumption.
Qed.

Theorem stores_only_execution_preserves_permissions :
  forall ge e le before statement trace le' after outcome,
    exec_stmt function_entry2 ge e le before statement trace le' after outcome ->
    stores_only_statement statement = true ->
    forall b offset kind permission,
      Mem.perm before b offset kind permission ->
      Mem.perm after b offset kind permission.
Proof.
  intros ge e le before statement trace le' after outcome Hexec.
  induction Hexec; cbn; intros Hsyntax protectedblock protectedoffset protectedkind protectedpermission Hperm;
    try discriminate; try exact Hperm;
    repeat match goal with H : _ && _ = true |- _ =>
      apply Bool.andb_true_iff in H; destruct H end;
    first [eapply assign_location_preserves_permissions; eassumption |
      eauto].
  all: try (destruct b; eauto).
  apply IHHexec3; [cbn; rewrite H0, H1; reflexivity |].
  apply IHHexec2; [exact H1 |]. eauto.
Qed.

Theorem stores_only_funcall_preserves_permissions :
  forall ge f args before trace after result,
    fn_vars f = nil -> stores_only_statement (fn_body f) = true ->
    eval_funcall function_entry2 ge before (Internal f) args trace after result ->
    forall b offset kind permission,
      Mem.perm before b offset kind permission ->
      Mem.perm after b offset kind permission.
Proof.
  intros ge f args before trace after result Hvars Hsyntax Hcall b offset kind permission Hperm.
  inversion Hcall; subst.
  match goal with H : function_entry2 _ _ _ _ _ _ _ |- _ => inversion H; subst end.
  rewrite Hvars in H6. inversion H6; subst.
  match goal with H : Mem.free_list _ (blocks_of_env _ empty_env) = Some _ |- _ =>
    cbn [blocks_of_env] in H; inversion H; subst end.
  eapply stores_only_execution_preserves_permissions; eassumption.
Qed.

Corollary stores_only_funcall_preserves_access :
  forall ge f args before trace after result,
    fn_vars f = nil -> stores_only_statement (fn_body f) = true ->
    eval_funcall function_entry2 ge before (Internal f) args trace after result ->
    forall chunk b offset permission,
      Mem.valid_access before chunk b offset permission ->
      Mem.valid_access after chunk b offset permission.
Proof.
  intros ge f args before trace after result Hvars Hsyntax Hcall chunk b offset permission
    [Hrange Halign]. split; [|exact Halign].
  intros address Haddress.
  eapply stores_only_funcall_preserves_permissions; try eassumption.
  apply Hrange. exact Haddress.
Qed.

Lemma generated_playback_stores_only :
  stores_only_statement (fn_body P.f_run_demo_inputs) = true.
Proof. reflexivity. Qed.

Definition controller_actual_demo_call (body : statement) : statement :=
  match body with Ssequence _ (Ssequence call _) => call | _ => Sskip end.

Definition controller_actual_first_setup (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _ (Ssequence
      (Ssequence initialize (Sloop (Ssequence guard
        (Ssequence install (Ssequence load _))) _)) _)) =>
      Ssequence initialize (Ssequence guard (Ssequence install load))
  | _ => Sskip
  end.

Definition controller_actual_connected_guard (body : statement) : expr :=
  match body with
  | Ssequence _ (Ssequence _ (Ssequence
      (Ssequence _ (Sloop (Ssequence _
        (Ssequence _ (Ssequence _ (Sifthenelse guard _ _)))) _)) _)) => guard
  | _ => Econst_int Int.zero tint
  end.

Lemma generated_actual_demo_call :
  controller_actual_demo_call (fn_body P.f_read_controller_inputs) =
    Scall None (Evar P._run_demo_inputs (Tfunction [] tvoid cc_default)) [].
Proof. reflexivity. Qed.

Lemma generated_actual_first_setup :
  controller_actual_first_setup (fn_body P.f_read_controller_inputs) =
    Ssequence (Sset P._i (Econst_int Int.zero tint))
      (Ssequence (Sifthenelse
        (Ebinop Olt (Etempvar P._i tint) (Econst_int (Int.repr 2) tint) tint)
        Sskip Sbreak)
        (Ssequence (Sset P._controller
          (Ebinop Oadd (Evar P._gControllers (tarray (Tstruct P._Controller noattr) 3))
            (Etempvar P._i tint) (tptr (Tstruct P._Controller noattr))))
          (Sset P._t'22 (Efield
            (Ederef (Etempvar P._controller (tptr (Tstruct P._Controller noattr)))
              (Tstruct P._Controller noattr)) P._controllerData
            (tptr (Tstruct P.__319 noattr)))))).
Proof. reflexivity. Qed.

Theorem generated_actual_first_controller_setup_executes :
  forall ge (layout : playback_layout ge) le before controllers pad,
    Genv.find_symbol ge P._gControllers = Some controllers ->
    Mem.load Mptr before controllers 24 = Some (Vptr pad Ptrofs.zero) ->
    Mem.valid_pointer before pad 0 = true ->
    exists lec,
      exec_stmt function_entry2 ge empty_env le before
        (controller_actual_first_setup (fn_body P.f_read_controller_inputs))
        E0 lec before Out_normal /\
      lec ! P._controller = Some (Vptr controllers Ptrofs.zero) /\
      eval_expr ge empty_env lec before
        (controller_actual_connected_guard (fn_body P.f_read_controller_inputs))
        (Vint Int.one).
Proof.
  intros ge layout le before controllers pad Hcontrollers Hpad Hvalid.
  destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
    Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  eexists. split.
  - unfold controller_actual_first_setup.
    cbn [P.f_read_controller_inputs fn_body]. playback_stmt.
  - split.
    + cbn. repeat rewrite PTree.gsspec. reflexivity.
    + unfold controller_actual_connected_guard.
      cbn [P.f_read_controller_inputs fn_body]. playback_expr.
Qed.

Definition consumed_record_copy_boundary (body : statement) : statement :=
  Ssequence (controller_actual_demo_call body)
    (Ssequence (controller_actual_first_setup body)
      (Sifthenelse (controller_actual_connected_guard body)
        (controller_copy_prefix body) Sskip)).

Lemma writable_pad_has_valid_pointer : forall before pad,
  Mem.valid_access before Mint16unsigned pad 0 Writable ->
  Mem.valid_pointer before pad 0 = true.
Proof.
  intros before pad Haccess. apply Mem.valid_pointer_nonempty_perm.
  eapply Mem.perm_implies.
  - exact (proj1 Haccess 0 ltac:(cbn; lia)).
  - constructor.
Qed.

Definition controller_actual_post_poll_body (body : statement) : statement :=
  match body with Ssequence _ rest => rest | _ => Sskip end.
Definition controller_actual_loop_body (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _ (Ssequence (Ssequence _ (Sloop loop _)) _)) => loop
  | _ => Sskip end.
Definition controller_actual_loop_increment (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _ (Ssequence (Ssequence _ (Sloop _ increment)) _)) => increment
  | _ => Sskip end.
Definition controller_actual_player3_copy (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _ (Ssequence _ copy)) => copy
  | _ => Sskip end.
Definition controller_actual_analog_call (body : statement) : statement :=
  let '(_, _, _, _, analog) := controller_copy_stages body in analog.
Definition controller_actual_analog_cont (body : statement) (k : cont) : cont :=
  Kloop1 (controller_actual_loop_body body) (controller_actual_loop_increment body)
    (Kseq (controller_actual_player3_copy body) k).

Lemma input_normal_execution_steps :
  forall (prog : Clight.program) e le before statement le' after f k,
    exec_stmt function_entry2 (Clight.globalenv prog) e le before statement E0 le' after Out_normal ->
    star step2 (Clight.globalenv prog) (State f statement k e le before) E0
      (State f Sskip k e le' after).
Proof.
  intros prog e le before statement le' after f k Hexec.
  destruct (exec_stmt_steps function_entry2 prog e le before statement E0 le' after
    Out_normal Hexec f k) as (state' & Hsteps & Hout).
  inversion Hout; subst. exact Hsteps.
Qed.

Ltac input_small_step rule :=
  eapply star_left with (t1 := E0) (t2 := E0); [apply rule | |reflexivity].
Ltac input_big_step H :=
  eapply star_trans with (t1 := E0) (t2 := E0);
    [eapply input_normal_execution_steps; exact H | |reflexivity].

Lemma actual_input_loop_reaches_analog_boundary :
  forall (prog : Clight.program) le before played lec after le' k,
    exec_stmt function_entry2 (Clight.globalenv prog) empty_env le before
      (controller_actual_demo_call (fn_body P.f_read_controller_inputs)) E0 le played Out_normal ->
    exec_stmt function_entry2 (Clight.globalenv prog) empty_env le played
      (controller_actual_first_setup (fn_body P.f_read_controller_inputs)) E0 lec played Out_normal ->
    eval_expr (Clight.globalenv prog) empty_env lec played
      (controller_actual_connected_guard (fn_body P.f_read_controller_inputs)) (Vint Int.one) ->
    exec_stmt function_entry2 (Clight.globalenv prog) empty_env lec played
      (controller_copy_prefix (fn_body P.f_read_controller_inputs)) E0 le' after Out_normal ->
    star step2 (Clight.globalenv prog)
      (State P.f_read_controller_inputs
        (controller_actual_post_poll_body (fn_body P.f_read_controller_inputs))
        k empty_env le before) E0
      (State P.f_read_controller_inputs
        (controller_actual_analog_call (fn_body P.f_read_controller_inputs))
        (controller_actual_analog_cont (fn_body P.f_read_controller_inputs) k)
        empty_env le' after).
Proof.
  intros prog le before played lec after le' k Hdemo Hsetup Hguard Hcopy.
  unfold controller_actual_demo_call, controller_actual_first_setup,
    controller_actual_connected_guard, controller_copy_prefix, controller_copy_stages,
    generated_connected_controller_branch, controller_actual_post_poll_body,
    controller_actual_analog_call, controller_actual_analog_cont,
    controller_actual_loop_body, controller_actual_loop_increment,
    controller_actual_player3_copy in *.
  cbn [P.f_read_controller_inputs fn_body] in *.
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hsetup)
    as (m1 & le1 & Hinitialize & Hsetup1).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hsetup1)
    as (m2 & le2 & Hloopguard & Hsetup2).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hsetup2)
    as (m3 & le3 & Hinstall & Hload).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hcopy)
    as (m4 & le4 & Hx & Hcopy1).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hcopy1)
    as (m5 & le5 & Hy & Hcopy2).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hcopy2)
    as (m6 & le6 & Hpressed & Hdown).
  input_small_step step_seq. input_big_step Hdemo.
  input_small_step step_skip_seq. input_small_step step_seq.
  input_small_step step_seq. input_big_step Hinitialize.
  input_small_step step_skip_seq. input_small_step step_loop.
  input_small_step step_seq. input_big_step Hloopguard.
  input_small_step step_skip_seq. input_small_step step_seq.
  input_big_step Hinstall. input_small_step step_skip_seq.
  input_small_step step_seq. input_big_step Hload.
  input_small_step step_skip_seq.
  eapply star_left with (t1 := E0) (t2 := E0).
  - eapply step_ifthenelse with (v1 := Vint Int.one) (b := true); [exact Hguard | reflexivity].
  - input_small_step step_seq. input_big_step Hx. input_small_step step_skip_seq.
    input_small_step step_seq. input_big_step Hy. input_small_step step_skip_seq.
    input_small_step step_seq. input_big_step Hpressed. input_small_step step_skip_seq.
    input_small_step step_seq. input_big_step Hdown. input_small_step step_skip_seq.
    apply star_refl.
  - reflexivity.
Qed.

(** A real ordinary playback call followed by the actual first-controller
    setup/guard and four-store copy boundary.  This intentionally stops before
    analog adjustment and before completion of the surrounding loop. *)
Definition demo_consumed_record_start_boundary_claim (f : function) (body : statement) : Prop :=
  forall ge (layout : controller_input_layout ge) le before
      controllers current pad stream record run physical timer rawx rawy mask previous,
    Genv.find_symbol ge P._gControllers = Some controllers ->
    Genv.find_symbol ge P._gCurrDemoInput = Some current ->
    Genv.find_symbol ge P._run_demo_inputs = Some run ->
    Genv.find_funct ge (Vptr run Ptrofs.zero) = Some (Internal f) ->
    controllers <> current ->
    pad <> controllers -> pad <> current -> pad <> stream ->
    stream <> controllers -> stream <> current ->
    Mem.load Mptr before controllers 24 = Some (Vptr pad Ptrofs.zero) ->
    Mem.load Mptr before controllers 52 = Some Vzero ->
    Mem.load Mptr before current 0 = Some (Vptr stream record) ->
    Mem.valid_pointer before stream (Ptrofs.unsigned record) = true ->
    Mem.load Mint16unsigned before pad 0 = Some (Vint physical) ->
    Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
    Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
    Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
    Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
    Mem.load Mint16unsigned before controllers 16 = Some (Vint previous) ->
    Int.eq timer Int.zero = false ->
    Int.testbit physical 12 = true ->
    Int.testbit previous 12 = false ->
    Mem.valid_access before Mint16unsigned pad 0 Writable ->
    Mem.valid_access before Mint8signed pad 2 Writable ->
    Mem.valid_access before Mint8signed pad 3 Writable ->
    Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
    Mem.valid_access before Mptr current 0 Writable ->
    Mem.valid_access before Mint16signed controllers 0 Writable ->
    Mem.valid_access before Mint16signed controllers 2 Writable ->
    Mem.valid_access before Mint16unsigned controllers 18 Writable ->
    Mem.valid_access before Mint16unsigned controllers 16 Writable ->
    exists after le',
      exec_stmt function_entry2 ge empty_env le before
        (consumed_record_copy_boundary body) E0 le' after Out_normal /\
      Mem.load Mint16signed after controllers 0 = Some (Vint rawx) /\
      Mem.load Mint16signed after controllers 2 = Some (Vint rawy) /\
      Mem.load Mint16unsigned after controllers 18 = Some (Vint
        (controller_pressed_value (playback_output_buttons physical mask) previous)) /\
      Mem.load Mint16unsigned after controllers 16 =
        Some (Vint (playback_output_buttons physical mask)) /\
      Int.eq (Int.and (controller_pressed_value
        (playback_output_buttons physical mask) previous) (Int.repr 4096)) Int.zero = false /\
      Int.eq (Int.and (controller_pressed_value
        (playback_output_buttons physical mask) previous) (Int.repr 128)) Int.zero = true /\
      Mem.load Mptr after current 0 = Some (Vptr stream (playback_next_record timer record)) /\
      Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) =
        Some (Vint (playback_next_timer timer)) /\
      (4 <= Ptrofs.unsigned record ->
        Mem.load Mint32 after stream 0 = Mem.load Mint32 before stream 0) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset current 0 4 ->
        playback_read_avoids chunk b offset pad 0 4 ->
        playback_read_avoids chunk b offset stream (Ptrofs.unsigned record)
          (Ptrofs.unsigned record + 1) ->
        playback_read_avoids chunk b offset controllers 0 4 ->
        playback_read_avoids chunk b offset controllers 16 20 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      (forall prog : Clight.program, ge = Clight.globalenv prog -> forall k,
        star step2 ge
          (State P.f_read_controller_inputs (controller_actual_post_poll_body body)
            k empty_env le before) E0
          (State P.f_read_controller_inputs (controller_actual_analog_call body)
            (controller_actual_analog_cont body k) empty_env le' after)).

Theorem generated_consumed_record_start_boundary :
  demo_consumed_record_start_boundary_claim P.f_run_demo_inputs
    (fn_body P.f_read_controller_inputs).
Proof.
  unfold demo_consumed_record_start_boundary_claim.
  intros ge layout le before controllers current pad stream record run physical timer rawx rawy mask previous
    Hcontrollers Hcurrent Hrun Hfindrun Hcg Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid
    Hphysical Htimer Hrawx Hrawy Hmask Hprevious Hpositive Hphysicalstart Hpreviousstart
    Hwbuttons Hwx Hwy Hwtimer Hwcurrent Hwcrawx Hwcrawy Hwcpressed Hwcdown.
  destruct (generated_playback_all_timers_call ge (input_playback_layout ge layout)
    before controllers current pad stream record physical timer rawx rawy mask
    Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
    Htimer Hrawx Hrawy Hmask Hwbuttons Hwx Hwy Hwtimer Hwcurrent)
    as (played & Hplayed & Hpointer' & Htimer' & Hrawx' & Hrawy' & Hbuttons' & Hplayframe & Hheader).
  unfold playback_next_stick, playback_next_buttons in Hrawx', Hrawy', Hbuttons'.
  rewrite Hpositive in Hrawx', Hrawy', Hbuttons'.
  assert (Haccess : forall chunk b offset permission,
    Mem.valid_access before chunk b offset permission ->
    Mem.valid_access played chunk b offset permission).
  { intros. eapply stores_only_funcall_preserves_access with
      (f := P.f_run_demo_inputs) (args := []) (before := before)
      (trace := E0) (result := Vundef).
    - reflexivity.
    - exact generated_playback_stores_only.
    - exact Hplayed.
    - eassumption. }
  assert (Hcontroller_reads : forall chunk offset,
    Mem.load chunk played controllers offset = Mem.load chunk before controllers offset).
  { intros chunk offset. apply Hplayframe; unfold playback_read_avoids; left; congruence. }
  assert (Hpad' : Mem.load Mptr played controllers 24 = Some (Vptr pad Ptrofs.zero)).
  { rewrite Hcontroller_reads. exact Hpad. }
  assert (Hprevious' : Mem.load Mint16unsigned played controllers 16 = Some (Vint previous)).
  { rewrite Hcontroller_reads. exact Hprevious. }
  destruct (generated_actual_first_controller_setup_executes ge
    (input_playback_layout ge layout) le played controllers pad Hcontrollers Hpad'
    (writable_pad_has_valid_pointer played pad (Haccess _ _ _ _ Hwbuttons)))
    as (lec & Hsetup & Hcontroller & Hguard).
  destruct (generated_controller_copy_prefix_executes ge layout lec played
    controllers pad rawx rawy (playback_output_buttons physical mask) previous
    Hcontroller ltac:(congruence) Hpad' Hrawx' Hrawy' Hbuttons' Hprevious'
    (Haccess _ _ _ _ Hwcrawx) (Haccess _ _ _ _ Hwcrawy)
    (Haccess _ _ _ _ Hwcpressed) (Haccess _ _ _ _ Hwcdown))
    as (after & le' & Hcopy & Hcopiedx & Hcopiedy & Hpressed & Hdown & Hcopyframe & Hrest).
  destruct (controller_new_physical_start_satisfies_actual_guards physical mask previous
    Hphysicalstart Hpreviousstart) as [Hstart Hend].
  assert (Hcallstmt : exec_stmt function_entry2 ge empty_env le before
    (controller_actual_demo_call (fn_body P.f_read_controller_inputs)) E0 le played Out_normal).
  { rewrite generated_actual_demo_call. eapply exec_Scall with (optid := None) (vres := Vundef).
    - reflexivity.
    - playback_expr.
    - constructor.
    - exact Hfindrun.
    - reflexivity.
    - exact Hplayed. }
  exists after, le'. split.
  - unfold consumed_record_copy_boundary.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + exact Hcallstmt.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hsetup |].
      eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
      * exact Hguard.
      * reflexivity.
      * exact Hcopy.
  - split; [exact Hcopiedx |]. split; [exact Hcopiedy |].
    split; [exact Hpressed |]. split; [exact Hdown |].
    split; [exact Hstart |]. split; [exact Hend |]. split.
    + rewrite Hcopyframe by (unfold playback_read_avoids; left; congruence).
      exact Hpointer'.
    + split.
      * rewrite Hcopyframe by (unfold playback_read_avoids; left; congruence).
        exact Htimer'.
      * split.
        -- intros Hfirst. rewrite Hcopyframe by (unfold playback_read_avoids; left; congruence).
           apply Hheader. exact Hfirst.
        -- split.
           ++ intros chunk b offset Hbg Hbp Hbs Hbcraw Hbcbuttons.
              rewrite Hcopyframe by assumption. apply Hplayframe; assumption.
           ++ intros prog Hge k. subst ge.
              eapply actual_input_loop_reaches_analog_boundary; eassumption.
Qed.

Definition demo_consumed_record_start_boundary_claim_us_jp : Prop :=
  demo_consumed_record_start_boundary_claim P.f_run_demo_inputs
    (fn_body P.f_read_controller_inputs) /\
  demo_consumed_record_start_boundary_claim jp_game_init.f_run_demo_inputs
    (fn_body jp_game_init.f_read_controller_inputs).

Theorem generated_demo_consumed_record_start_boundary_us_jp :
  demo_consumed_record_start_boundary_claim_us_jp.
Proof. split; exact generated_consumed_record_start_boundary. Qed.
