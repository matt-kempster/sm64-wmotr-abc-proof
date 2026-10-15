From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop Ctypes
  Errors Events Floats Globalenvs Integers Maps Memdata Memory Smallstep Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoPlaybackExecution
  DemoPlaybackAdvanceExecution DemoControllerInputExecution DemoConsumedInputExecution
  DemoAnalogInputExecution DemoControllerCopyExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

(** Caller temporary preservation is checked on actual statements.  Callee
    executions remain explicit in the enclosing execution derivation. *)
Fixpoint controller_keeps_temp (protected : ident) (s : statement) : bool :=
  match s with
  | Sset id _ | Scall (Some id) _ _ | Sbuiltin (Some id) _ _ _ =>
      negb (Pos.eqb protected id)
  | Ssequence a b | Sloop a b | Sifthenelse _ a b =>
      controller_keeps_temp protected a && controller_keeps_temp protected b
  | Sswitch _ _ | Slabel _ _ => false
  | _ => true
  end.

Lemma controller_execution_keeps_temp :
  forall ge e le before s trace le' after outcome,
    exec_stmt function_entry2 ge e le before s trace le' after outcome ->
    forall protected, controller_keeps_temp protected s = true ->
      le' ! protected = le ! protected.
Proof.
  intros ge e le before s trace le' after outcome Hexec.
  induction Hexec; intros protected Hsyntax; cbn in Hsyntax; try discriminate;
    try reflexivity;
    repeat match goal with H : _ && _ = true |- _ =>
      apply Bool.andb_true_iff in H; destruct H end;
    try (destruct b; eauto); try congruence.
  all: try (match goal with
    | H : negb (Pos.eqb _ _) = true |- _ =>
      apply Bool.negb_true_iff, Pos.eqb_neq in H;
      rewrite PTree.gso by congruence; reflexivity
    end).
  all: try (destruct optid; cbn [set_opttemp] in *; [|reflexivity];
    apply Bool.negb_true_iff, Pos.eqb_neq in Hsyntax;
    rewrite PTree.gso by congruence; reflexivity).
  all: repeat match goal with
  | IH : forall id, controller_keeps_temp id ?statement = true -> _ |- _ =>
      let Heq := fresh "Htemporary" in
      assert (Heq := IH protected ltac:(cbn; repeat rewrite Bool.andb_true_iff; tauto));
      clear IH
  end.
  all: congruence.
Qed.

Definition controller_iteration_setup (body : statement) : statement :=
  match controller_actual_loop_body body with
  | Ssequence guard (Ssequence install _) => Ssequence guard install
  | _ => Sskip
  end.

Lemma generated_second_controller_setup_executes :
  forall ge (layout : playback_layout ge) le before controllers,
    Genv.find_symbol ge P._gControllers = Some controllers ->
    le ! P._i = Some (Vint (Int.repr 1)) ->
    exec_stmt function_entry2 ge empty_env le before
      (controller_iteration_setup (fn_body P.f_read_controller_inputs))
      E0 (PTree.set P._controller (Vptr controllers (Ptrofs.repr 28)) le)
      before Out_normal.
Proof.
  intros ge layout le before controllers Hcontrollers Hindex.
  destruct layout as [controller_co pad_co record_co Hcontroller Hpad Hrecord
    Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  unfold controller_iteration_setup, controller_actual_loop_body.
  cbn [P.f_read_controller_inputs fn_body].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
      [playback_expr | reflexivity | constructor].
  - apply exec_Sset. playback_expr.
Qed.

Lemma generated_controller_loop_increment_executes :
  forall ge le before index,
    le ! P._i = Some (Vint index) ->
    exec_stmt function_entry2 ge empty_env le before
      (controller_actual_loop_increment (fn_body P.f_read_controller_inputs))
      E0 (PTree.set P._i (Vint (Int.add index (Int.repr 1))) le) before Out_normal.
Proof.
  intros ge le before index Hindex.
  unfold controller_actual_loop_increment. cbn [P.f_read_controller_inputs fn_body].
  apply exec_Sset. playback_expr.
Qed.

Ltac input_continue_loop :=
  eapply star_left with (t1 := E0) (t2 := E0);
    [apply step_skip_or_continue_loop1; left; reflexivity | |reflexivity].

Theorem actual_controller_post_polling_composition_steps :
  forall (prog : Clight.program) le before played lec first le1 le2 second le3 after le4 k,
    exec_stmt function_entry2 (Clight.globalenv prog) empty_env le before
      (controller_actual_demo_call (fn_body P.f_read_controller_inputs)) E0 le played Out_normal ->
    exec_stmt function_entry2 (Clight.globalenv prog) empty_env le played
      (controller_actual_first_setup (fn_body P.f_read_controller_inputs)) E0 lec played Out_normal ->
    eval_expr (Clight.globalenv prog) empty_env lec played
      (controller_actual_connected_guard (fn_body P.f_read_controller_inputs)) (Vint Int.one) ->
    exec_stmt function_entry2 (Clight.globalenv prog) empty_env lec played
      (generated_connected_controller_branch (fn_body P.f_read_controller_inputs))
      E0 le1 first Out_normal ->
    le1 ! P._i = Some Vzero ->
    exec_stmt function_entry2 (Clight.globalenv prog) empty_env
      (PTree.set P._i (Vint (Int.repr 1)) le1) first
      (controller_iteration_setup (fn_body P.f_read_controller_inputs)) E0 le2 first Out_normal ->
    exec_stmt function_entry2 (Clight.globalenv prog) empty_env le2 first
      (controller_data_decision (fn_body P.f_read_controller_inputs)) E0 le3 second Out_normal ->
    le3 ! P._i = Some (Vint (Int.repr 1)) ->
    exec_stmt function_entry2 (Clight.globalenv prog) empty_env
      (PTree.set P._i (Vint (Int.repr 2)) le3) second
      (controller_player3_suffix (fn_body P.f_read_controller_inputs)) E0 le4 after Out_normal ->
    star step2 (Clight.globalenv prog)
      (State P.f_read_controller_inputs
        (controller_actual_post_poll_body (fn_body P.f_read_controller_inputs))
        k empty_env le before) E0
      (State P.f_read_controller_inputs Sskip k empty_env le4 after).
Proof.
  intros prog le before played lec first le1 le2 second le3 after le4 k
    Hdemo Hsetup Hguard Hfirst Hi0 Hsetup2 Hsecond Hi1 Hcopy.
  pose proof (generated_controller_loop_increment_executes (Clight.globalenv prog) le1 first Int.zero Hi0)
    as Hinc1.
  pose proof (generated_controller_loop_increment_executes (Clight.globalenv prog) le3 second (Int.repr 1) Hi1)
    as Hinc2.
  change (exec_stmt function_entry2 (Clight.globalenv prog) empty_env le1 first
    (controller_actual_loop_increment (fn_body P.f_read_controller_inputs)) E0
    (PTree.set P._i (Vint (Int.repr 1)) le1) first Out_normal) in Hinc1.
  change (exec_stmt function_entry2 (Clight.globalenv prog) empty_env le3 second
    (controller_actual_loop_increment (fn_body P.f_read_controller_inputs)) E0
    (PTree.set P._i (Vint (Int.repr 2)) le3) second Out_normal) in Hinc2.
  unfold controller_actual_demo_call, controller_actual_first_setup,
    controller_actual_connected_guard, generated_connected_controller_branch,
    controller_actual_post_poll_body, controller_iteration_setup,
    controller_actual_loop_body, controller_actual_loop_increment,
    controller_data_decision, controller_player3_suffix in *.
  cbn [P.f_read_controller_inputs fn_body] in *.
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hsetup)
    as (m1 & let1 & Hinitialize & Hsetup1).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hsetup1)
    as (m2 & let2 & Hloopguard & Hsetup3).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hsetup3)
    as (m3 & let3 & Hinstall & Hload).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hsetup2)
    as (m4 & let4 & Hloopguard2 & Hinstall2).
  input_small_step step_seq. input_big_step Hdemo.
  input_small_step step_skip_seq. input_small_step step_seq.
  input_small_step step_seq. input_big_step Hinitialize.
  input_small_step step_skip_seq. input_small_step step_loop.
  input_small_step step_seq. input_big_step Hloopguard.
  input_small_step step_skip_seq. input_small_step step_seq.
  input_big_step Hinstall. input_small_step step_skip_seq.
  input_small_step step_seq. input_big_step Hload. input_small_step step_skip_seq.
  eapply star_left with (t1 := E0) (t2 := E0).
  - eapply step_ifthenelse with (v1 := Vint Int.one) (b := true); [exact Hguard | reflexivity].
  - input_big_step Hfirst. input_continue_loop. input_big_step Hinc1.
    input_small_step step_skip_loop2. input_small_step step_loop.
    input_small_step step_seq. input_big_step Hloopguard2.
    input_small_step step_skip_seq. input_small_step step_seq.
    input_big_step Hinstall2. input_small_step step_skip_seq.
    input_big_step Hsecond. input_continue_loop. input_big_step Hinc2.
    input_small_step step_skip_loop2. input_small_step step_loop.
    input_small_step step_seq.
    eapply star_left with (t1 := E0) (t2 := E0).
    + eapply step_ifthenelse with (v1 := Vzero) (b := false).
      * playback_expr.
      * reflexivity.
    + input_small_step step_break_seq. input_small_step step_break_loop1.
      input_small_step step_skip_seq. input_big_step Hcopy. apply star_refl.
    + reflexivity.
  - reflexivity.
Qed.

Theorem generated_connected_arbitrary_controller_executes :
  forall ge (layout : controller_input_layout ge) le before
      controller pad analog sqrt rawx rawy buttons previous magnitude,
    le ! P._controller = Some (Vptr controller Ptrofs.zero) ->
    controller <> pad ->
    Genv.find_symbol ge P._adjust_analog_stick = Some analog ->
    Genv.find_funct ge (Vptr analog Ptrofs.zero) = Some (Internal P.f_adjust_analog_stick) ->
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle (arbitrary_analog_square_sum rawx rawy)] m E0 (Vsingle magnitude) m) ->
    Mem.load Mptr before controller 24 = Some (Vptr pad Ptrofs.zero) ->
    Mem.load Mint8signed before pad 2 = Some (Vint rawx) ->
    Mem.load Mint8signed before pad 3 = Some (Vint rawy) ->
    Mem.load Mint16unsigned before pad 0 = Some (Vint buttons) ->
    Mem.load Mint16unsigned before controller 16 = Some (Vint previous) ->
    Mem.valid_access before Mint16signed controller 0 Writable ->
    Mem.valid_access before Mint16signed controller 2 Writable ->
    Mem.valid_access before Mint16unsigned controller 18 Writable ->
    Mem.valid_access before Mint16unsigned controller 16 Writable ->
    Mem.valid_access before Mfloat32 controller 4 Writable ->
    Mem.valid_access before Mfloat32 controller 8 Writable ->
    Mem.valid_access before Mfloat32 controller 12 Writable ->
    exists after le',
      exec_stmt function_entry2 ge empty_env le before
        (generated_connected_controller_branch (fn_body P.f_read_controller_inputs))
        E0 le' after Out_normal /\
      Mem.load Mint16signed after controller 0 = Some (Vint rawx) /\
      Mem.load Mint16signed after controller 2 = Some (Vint rawy) /\
      Mem.load Mint16unsigned after controller 18 =
        Some (Vint (controller_pressed_value buttons previous)) /\
      Mem.load Mint16unsigned after controller 16 = Some (Vint buttons) /\
      Mem.load Mfloat32 after controller 4 = Some (Vsingle (arbitrary_analog_final_axis rawx magnitude)) /\
      Mem.load Mfloat32 after controller 8 = Some (Vsingle (arbitrary_analog_final_axis rawy magnitude)) /\
      Mem.load Mfloat32 after controller 12 = Some (Vsingle (arbitrary_analog_final_magnitude magnitude)) /\
      (forall chunk b offset,
        Mem.valid_block before b ->
        playback_read_avoids chunk b offset controller 0 20 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      le' ! P._controller = Some (Vptr controller Ptrofs.zero) /\
      le' ! P._i = le ! P._i /\
      (forall chunk b offset permission,
        Mem.valid_access before chunk b offset permission ->
        Mem.valid_access after chunk b offset permission).
Proof.
  intros ge layout le before controller pad analog sqrt rawx rawy buttons previous magnitude
    Hcontroller Hseparate Hanalog Hfindanalog Hsqrt Hfind Hmath Hpad
    Hrawx Hrawy Hbuttons Hprevious Hwx Hwy Hwpressed Hwdown Hwsx Hwsy Hwmag.
  destruct (generated_controller_copy_prefix_executes ge layout le before
    controller pad rawx rawy buttons previous Hcontroller Hseparate Hpad
    Hrawx Hrawy Hbuttons Hprevious Hwx Hwy Hwpressed Hwdown)
    as (copied & lec & Hprefix & Hrawx' & Hrawy' & Hpressed & Hdown & Hcopyframe &
      Hcontroller' & Haccess & Hvalid).
  destruct (generated_arbitrary_analog_call_executes ge layout copied controller
    sqrt rawx rawy magnitude Hsqrt Hfind Hmath Hrawx' Hrawy'
    (Haccess Mfloat32 controller 4 Writable Hwsx)
    (Haccess Mfloat32 controller 8 Writable Hwsy)
    (Haccess Mfloat32 controller 12 Writable Hwmag))
    as (after & Hcall & Hsx & Hsy & Hmag & Hanalogframe & Hanalogpermissions & Hanalogaccess).
  assert (Hvalidcontroller : Mem.valid_block copied controller).
  { eapply Mem.valid_access_valid_block. eapply Mem.valid_access_implies.
    - eapply Mem.load_valid_access. exact Hrawx'.
    - constructor. }
  exists after, lec. split.
  - eapply controller_prefix_then_analog; [exact Hprefix |].
    cbn [controller_copy_stages generated_connected_controller_branch P.f_read_controller_inputs fn_body].
    eapply exec_Scall with (optid := None) (vres := Vundef).
    + reflexivity.
    + analog_expr.
    + analog_arguments.
    + exact Hfindanalog.
    + reflexivity.
    + exact Hcall.
  - do 4 (split; [rewrite Hanalogframe by
      (try exact Hvalidcontroller; unfold playback_read_avoids;
        first [right; left; cbn; lia | right; right; cbn; lia]); eassumption |]).
    split; [exact Hsx |]. split; [exact Hsy |]. split; [exact Hmag |]. split.
    + intros chunk b offset Hvb Havoid. unfold playback_read_avoids in Havoid.
      rewrite Hanalogframe.
      * apply Hcopyframe; unfold playback_read_avoids;
          destruct Havoid as [H | [H | H]];
          first [left; exact H | right; left; exact H | right; left; cbn; lia | right; right; cbn; lia].
      * apply Hvalid. exact Hvb.
      * unfold playback_read_avoids. destruct Havoid as [H | [H | H]];
          first [left; exact H | right; left; exact H | right; left; cbn; lia | right; right; cbn; lia].
    + split; [exact Hcontroller' |]. split.
      * eapply controller_execution_keeps_temp; [exact Hprefix | reflexivity].
      * intros. apply Hanalogaccess, Haccess. assumption.
Qed.

Lemma generated_first_setup_installs_index_zero :
  forall ge le before lec,
    exec_stmt function_entry2 ge empty_env le before
      (controller_actual_first_setup (fn_body P.f_read_controller_inputs))
      E0 lec before Out_normal ->
    lec ! P._i = Some Vzero.
Proof.
  intros ge le before lec Hexec.
  rewrite generated_actual_first_setup in Hexec.
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hexec)
    as (m1 & le1 & Hinit & Hrest).
  inversion Hinit; subst.
  match goal with H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inversion H; subst end.
  all: try match goal with H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inversion H end.
  all: rewrite (controller_execution_keeps_temp _ _ _ _ _ _ _ _ _ Hrest P._i ltac:(reflexivity)).
  all: rewrite PTree.gss; reflexivity.
Qed.

Lemma controller_loaded_block_valid : forall chunk memory b offset value,
  Mem.load chunk memory b offset = Some value -> Mem.valid_block memory b.
Proof.
  intros. eapply Mem.valid_access_valid_block, Mem.valid_access_implies.
  - eapply Mem.load_valid_access; eassumption.
  - constructor.
Qed.

Lemma controller_read_avoids_subrange : forall chunk b offset controllers first past smallfirst smallpast,
  first <= smallfirst -> smallpast <= past ->
  playback_read_avoids chunk b offset controllers first past ->
  playback_read_avoids chunk b offset controllers smallfirst smallpast.
Proof. unfold playback_read_avoids. intros; intuition lia. Qed.

Lemma controller_region_valid_access : forall before controllers,
  Mem.range_perm before controllers 0 84 Cur Writable ->
  forall chunk offset, 0 <= offset -> offset + size_chunk chunk <= 84 ->
  (align_chunk chunk | offset) -> Mem.valid_access before chunk controllers offset Writable.
Proof.
 intros before controllers Hregion chunk offset Hfirst Hpast Halign.
 split; [|exact Halign]. intros address Haddress. apply Hregion. lia.
Qed.

Definition controller_post_polling_demo_claim (reader runbody : function) : Prop :=
 forall (prog : Clight.program) (layout : controller_input_layout (Clight.globalenv prog)) le before
   controllers current pad stream record run analog sqrt player1 player3
   physical timer rawx rawy mask previous magnitude header,
 Genv.find_symbol (Clight.globalenv prog) P._gControllers = Some controllers ->
 Genv.find_symbol (Clight.globalenv prog) P._gCurrDemoInput = Some current ->
 Genv.find_symbol (Clight.globalenv prog) P._run_demo_inputs = Some run ->
 Genv.find_funct (Clight.globalenv prog) (Vptr run Ptrofs.zero) = Some (Internal runbody) ->
 Genv.find_symbol (Clight.globalenv prog) P._adjust_analog_stick = Some analog ->
 Genv.find_funct (Clight.globalenv prog) (Vptr analog Ptrofs.zero) = Some (Internal P.f_adjust_analog_stick) ->
 Genv.find_symbol (Clight.globalenv prog) P._sqrtf = Some sqrt ->
 Genv.find_funct (Clight.globalenv prog) (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
 Genv.find_symbol (Clight.globalenv prog) P._gPlayer1Controller = Some player1 ->
 Genv.find_symbol (Clight.globalenv prog) P._gPlayer3Controller = Some player3 ->
 (forall memory, external_call controller_sqrt_external (Clight.globalenv prog)
   [Vsingle (arbitrary_analog_square_sum (playback_next_stick timer rawx) (playback_next_stick timer rawy))] memory E0 (Vsingle magnitude) memory) ->
 controllers <> current ->
 pad <> controllers -> pad <> current -> pad <> stream ->
 stream <> controllers -> stream <> current ->
 player1 <> controllers -> player1 <> current -> player1 <> pad -> player1 <> stream ->
 player3 <> controllers -> player3 <> current -> player3 <> pad -> player3 <> stream ->
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
 Mem.load Mptr before player1 0 = Some (Vptr controllers Ptrofs.zero) ->
 Mem.load Mptr before player3 0 = Some (Vptr controllers (Ptrofs.repr 56)) ->
 Mem.load Mint32 before stream 0 = Some (Vint header) ->
 4 <= Ptrofs.unsigned record ->
 Mem.valid_access before Mint16unsigned pad 0 Writable ->
 Mem.valid_access before Mint8signed pad 2 Writable ->
 Mem.valid_access before Mint8signed pad 3 Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 Mem.valid_access before Mptr current 0 Writable ->
 Mem.range_perm before controllers 0 84 Cur Writable ->
 exists after le',
 (forall k, star step2 (Clight.globalenv prog)
   (State reader (controller_actual_post_poll_body (fn_body reader)) k empty_env le before) E0
   (State reader Sskip k empty_env le' after)) /\
 Mem.load Mint16signed after controllers 0 = Some (Vint (playback_next_stick timer rawx)) /\
 Mem.load Mint16signed after controllers 2 = Some (Vint (playback_next_stick timer rawy)) /\
 Mem.load Mint16unsigned after controllers 18 = Some (Vint
   (controller_pressed_value (playback_next_buttons timer physical mask) previous)) /\
 Mem.load Mint16unsigned after controllers 16 = Some (Vint (playback_next_buttons timer physical mask)) /\
 Mem.load Mfloat32 after controllers 4 = Some (Vsingle (arbitrary_analog_final_axis (playback_next_stick timer rawx) magnitude)) /\
 Mem.load Mfloat32 after controllers 8 = Some (Vsingle (arbitrary_analog_final_axis (playback_next_stick timer rawy) magnitude)) /\
 Mem.load Mfloat32 after controllers 12 = Some (Vsingle (arbitrary_analog_final_magnitude magnitude)) /\
 Mem.load Mint16unsigned after controllers 74 = Some (Vint
   (controller_pressed_value (playback_next_buttons timer physical mask) previous)) /\
 Mem.load Mint16unsigned after controllers 72 = Some (Vint (playback_next_buttons timer physical mask)) /\
 Mem.load Mptr after current 0 = Some (Vptr stream (playback_next_record timer record)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_next_timer timer)) /\
 Mem.load Mint32 after stream 0 = Some (Vint header) /\
 (forall chunk b offset value,
   Mem.load chunk before b offset = Some value ->
   playback_read_avoids chunk b offset current 0 4 ->
   playback_read_avoids chunk b offset pad 0 4 ->
   playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record + 1) ->
   playback_read_avoids chunk b offset controllers 0 76 ->
   Mem.load chunk after b offset = Some value).

Theorem generated_controller_post_polling_demo_executes :
  controller_post_polling_demo_claim P.f_read_controller_inputs P.f_run_demo_inputs.
Proof.
 unfold controller_post_polling_demo_claim.
 intros prog layout le before controllers current pad stream record run analog sqrt player1 player3
   physical timer rawx rawy mask previous magnitude header
   Hcontrollers Hcurrent Hrun Hfindrun Hanalog Hfindanalog Hsqrt Hfindsqrt Hplayer1 Hplayer3 Hmath
   Hcg Hpc Hpg Hps Hsc Hsg H1c H1g H1p H1s H3c H3g H3p H3s
   Hpad Hpad2 Hpointer Hvalid Hphysical Htimer Hrawx Hrawy Hmask Hprevious Hpointer1 Hpointer3
   Hheader Hfirst Hwbuttons Hwx Hwy Hwtimer Hwcurrent Hregion.
 pose proof (controller_region_valid_access before controllers Hregion) as Hwcontrollers.
 destruct (generated_playback_all_timers_call (Clight.globalenv prog) (input_playback_layout _ layout)
   before controllers current pad stream record physical timer rawx rawy mask
   Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
   Htimer Hrawx Hrawy Hmask Hwbuttons Hwx Hwy Hwtimer Hwcurrent)
   as (played & Hplayed & Hpointer' & Htimer' & Hrawx' & Hrawy' & Hbuttons' & Hplayframe & Hheader').
 assert (Hplayaccess : forall chunk b offset permission,
   Mem.valid_access before chunk b offset permission -> Mem.valid_access played chunk b offset permission).
 { abstract (intros; eapply stores_only_funcall_preserves_access with
     (f := P.f_run_demo_inputs) (args := []) (before := before) (trace := E0) (result := Vundef);
     [reflexivity | exact generated_playback_stores_only | exact Hplayed | eassumption]). }
 assert (Hplayreadonly : forall chunk b offset,
   b <> current -> b <> pad -> b <> stream ->
   Mem.load chunk played b offset = Mem.load chunk before b offset).
 { abstract (intros; apply Hplayframe; unfold playback_read_avoids; left; assumption). }
 assert (Hpad' : Mem.load Mptr played controllers 24 = Some (Vptr pad Ptrofs.zero)).
 { rewrite Hplayreadonly by first [assumption | apply not_eq_sym; assumption]. exact Hpad. }
 assert (Hprevious' : Mem.load Mint16unsigned played controllers 16 = Some (Vint previous)).
 { rewrite Hplayreadonly by first [assumption | apply not_eq_sym; assumption]. exact Hprevious. }
 destruct (generated_actual_first_controller_setup_executes (Clight.globalenv prog)
   (input_playback_layout _ layout) le played controllers pad Hcontrollers Hpad'
   (writable_pad_has_valid_pointer played pad (Hplayaccess _ _ _ _ Hwbuttons)))
   as (lec & Hsetup & Hcontroller & Hguard).
 pose proof (generated_first_setup_installs_index_zero _ _ _ _ Hsetup) as Hindex0.
 destruct (generated_connected_arbitrary_controller_executes (Clight.globalenv prog) layout lec played
   controllers pad analog sqrt (playback_next_stick timer rawx) (playback_next_stick timer rawy) (playback_next_buttons timer physical mask) previous magnitude
   Hcontroller ltac:(apply not_eq_sym; exact Hpc) Hanalog Hfindanalog Hsqrt Hfindsqrt Hmath Hpad'
   Hrawx' Hrawy' Hbuttons' Hprevious'
   ltac:(abstract (apply Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]])))
   as (first & le1 & Hfirstexec & Hfirstx & Hfirsty & Hfirstpressed & Hfirstdown &
     Hfirstsx & Hfirstsy & Hfirstmag & Hfirstframe & Hfirstcontroller & Hfirstindex & Hfirstaccess).
 assert (Hfirstread : forall chunk b offset value,
   Mem.load chunk played b offset = Some value ->
   playback_read_avoids chunk b offset controllers 0 20 ->
   Mem.load chunk first b offset = Some value).
 { abstract (intros chunk b offset value Hload Havoids; rewrite Hfirstframe;
     [exact Hload | eapply controller_loaded_block_valid; exact Hload | exact Havoids]). }
 set (incremented1 := PTree.set P._i (Vint (Int.repr 1)) le1).
 set (le2 := PTree.set P._controller (Vptr controllers (Ptrofs.repr 28)) incremented1).
 assert (Hsetup2 : exec_stmt function_entry2 (Clight.globalenv prog) empty_env incremented1 first
   (controller_iteration_setup (fn_body P.f_read_controller_inputs)) E0 le2 first Out_normal).
 { abstract (apply (generated_second_controller_setup_executes _ (input_playback_layout _ layout));
     [exact Hcontrollers | unfold incremented1; rewrite PTree.gss; reflexivity]). }
 assert (Hpad2' : Mem.load Mptr first controllers 52 = Some Vzero).
 { apply Hfirstread; [rewrite Hplayreadonly by first [assumption | apply not_eq_sym; assumption]; exact Hpad2 |
     unfold playback_read_avoids; right; right; cbn; lia]. }
 destruct (generated_disconnected_second_controller_executes (Clight.globalenv prog) layout true
   le2 first controllers ltac:(unfold le2; rewrite PTree.gss; reflexivity) Hpad2'
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]])))
   as (second & le3 & Hsecondexec & Hsecondcontroller & Hsecondindex & Hsecondframe & Hsecondaccess & Hsecondvalid).
 assert (Hsecondread : forall chunk b offset value,
   Mem.load chunk first b offset = Some value ->
   playback_read_avoids chunk b offset controllers 28 48 ->
   Mem.load chunk second b offset = Some value).
 { abstract (intros; eapply controller_load_preserved; eassumption). }
 set (incremented2 := PTree.set P._i (Vint (Int.repr 2)) le3).
 destruct (generated_player_three_copy_executes (Clight.globalenv prog) layout true incremented2 second
   controllers player1 player3 (playback_next_stick timer rawx) (playback_next_stick timer rawy)
   (arbitrary_analog_final_axis (playback_next_stick timer rawx) magnitude) (arbitrary_analog_final_axis (playback_next_stick timer rawy) magnitude)
   (arbitrary_analog_final_magnitude magnitude)
   (controller_pressed_value (playback_next_buttons timer physical mask) previous)
   (playback_next_buttons timer physical mask) Hplayer1 Hplayer3 H1c H3c
   ltac:(apply Hsecondread; [apply Hfirstread; [rewrite Hplayreadonly by assumption; exact Hpointer1 |
     unfold playback_read_avoids; left; exact H1c] | unfold playback_read_avoids; left; exact H1c])
   ltac:(apply Hsecondread; [apply Hfirstread; [rewrite Hplayreadonly by assumption; exact Hpointer3 |
     unfold playback_read_avoids; left; exact H3c] | unfold playback_read_avoids; left; exact H3c])
   ltac:(apply Hsecondread; [exact Hfirstx | unfold playback_read_avoids; right; left; cbn; lia])
   ltac:(apply Hsecondread; [exact Hfirsty | unfold playback_read_avoids; right; left; cbn; lia])
   ltac:(apply Hsecondread; [exact Hfirstsx | unfold playback_read_avoids; right; left; cbn; lia])
   ltac:(apply Hsecondread; [exact Hfirstsy | unfold playback_read_avoids; right; left; cbn; lia])
   ltac:(apply Hsecondread; [exact Hfirstmag | unfold playback_read_avoids; right; left; cbn; lia])
   ltac:(apply Hsecondread; [exact Hfirstpressed | unfold playback_read_avoids; right; left; cbn; lia])
   ltac:(apply Hsecondread; [exact Hfirstdown | unfold playback_read_avoids; right; left; cbn; lia])
   ltac:(abstract (apply Hsecondaccess, Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hsecondaccess, Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hsecondaccess, Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hsecondaccess, Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hsecondaccess, Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hsecondaccess, Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hsecondaccess, Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]])))
   as (after & le4 & Hcopy & Hcopycontroller & Hcopyindex & Hcopyx & Hcopyy & Hcopysx & Hcopysy &
     Hcopymag & Hcopypressed & Hcopydown & Hcopyframe & Hcopyaccess & Hcopyvalid).
 assert (Hcopyread : forall chunk b offset value,
   Mem.load chunk second b offset = Some value ->
   playback_read_avoids chunk b offset controllers 56 76 ->
   Mem.load chunk after b offset = Some value).
 { abstract (intros; eapply controller_load_preserved; eassumption). }
 assert (Hallfirstreads : forall chunk offset value,
   offset + size_chunk chunk <= 28 ->
   Mem.load chunk first controllers offset = Some value ->
   Mem.load chunk after controllers offset = Some value).
 { abstract (intros; apply Hcopyread; [apply Hsecondread; [assumption |] |];
     unfold playback_read_avoids; right; left; assumption || lia). }
 exists after, le4. split.
 - intros k. eapply actual_controller_post_polling_composition_steps with
     (played := played) (lec := lec) (first := first) (le1 := le1) (le2 := le2)
     (second := second) (le3 := le3).
   + rewrite generated_actual_demo_call. eapply exec_Scall with (optid := None) (vres := Vundef);
       [reflexivity | playback_expr | constructor | exact Hfindrun | reflexivity | exact Hplayed].
   + exact Hsetup.
   + exact Hguard.
   + exact Hfirstexec.
   + rewrite Hfirstindex. exact Hindex0.
   + exact Hsetup2.
   + exact Hsecondexec.
   + rewrite Hsecondindex. unfold le2, incremented1. rewrite PTree.gso by discriminate.
     rewrite PTree.gss. reflexivity.
   + exact Hcopy.
 - do 7 (split; [apply Hallfirstreads; [cbn; lia | eassumption] |]).
   split; [exact Hcopypressed |]. split; [exact Hcopydown |].
   assert (Hcontrolleronlyreads : forall chunk b offset value,
     b <> controllers -> Mem.load chunk played b offset = Some value ->
     Mem.load chunk after b offset = Some value).
   { abstract (intros; apply Hcopyread; [apply Hsecondread; [apply Hfirstread; [assumption |] |] |];
       unfold playback_read_avoids; left; assumption). }
   split; [apply Hcontrolleronlyreads; [apply not_eq_sym; exact Hcg | exact Hpointer'] |].
   split; [apply Hcontrolleronlyreads; [exact Hsc | exact Htimer'] |].
   split.
   + apply Hcontrolleronlyreads; [exact Hsc |]. rewrite Hheader' by exact Hfirst. exact Hheader.
   + intros chunk b offset value Hload Havoidcurrent Havoidpad Havoidtimer Havoidcontrollers.
     apply Hcopyread; [apply Hsecondread; [apply Hfirstread |] |].
     * rewrite Hplayframe by assumption. exact Hload.
     * eapply controller_read_avoids_subrange with (first := 0) (past := 76); [lia | lia | exact Havoidcontrollers].
     * eapply controller_read_avoids_subrange with (first := 0) (past := 76); [lia | lia | exact Havoidcontrollers].
     * eapply controller_read_avoids_subrange with (first := 0) (past := 76); [lia | lia | exact Havoidcontrollers].
Qed.

Definition demo_controller_post_polling_claim_us_jp : Prop :=
 controller_post_polling_demo_claim P.f_read_controller_inputs P.f_run_demo_inputs /\
 controller_post_polling_demo_claim jp_game_init.f_read_controller_inputs jp_game_init.f_run_demo_inputs.

Theorem generated_controller_post_polling_us_jp : demo_controller_post_polling_claim_us_jp.
Proof. split; exact generated_controller_post_polling_demo_executes. Qed.

(** The execution theorem above covers arbitrary physical and prior button
    values.  A new physical Start edge is a corollary of its exact final load. *)
Theorem controller_final_pressed_new_start_guards :
 forall after controllers timer physical mask previous pressed,
 Mem.load Mint16unsigned after controllers 18 = Some (Vint
   (controller_pressed_value (playback_next_buttons timer physical mask) previous)) ->
 Mem.load Mint16unsigned after controllers 18 = Some (Vint pressed) ->
 Int.eq timer Int.zero = false ->
 Int.testbit physical 12 = true -> Int.testbit previous 12 = false ->
 Int.eq (Int.and pressed (Int.repr 4096)) Int.zero = false /\
 Int.eq (Int.and pressed (Int.repr 128)) Int.zero = true.
Proof.
 intros after controllers timer physical mask previous pressed Hexpected Hactual Htimer Hphysical Hprevious.
 unfold playback_next_buttons in Hexpected. rewrite Htimer in Hexpected.
 rewrite Hexpected in Hactual. inversion Hactual; subst.
 apply controller_new_physical_start_satisfies_actual_guards; assumption.
Qed.

Theorem controller_eof_satisfies_actual_guards :
 forall previous,
 Int.testbit previous 7 = false ->
 Int.eq (Int.and (controller_pressed_value (Int.repr 128) previous)
   (Int.repr 128)) Int.zero = false /\
 Int.eq (Int.and (controller_pressed_value (Int.repr 128) previous)
   (Int.repr 4096)) Int.zero = true.
Proof.
 intros previous Hprevious.
 assert (Hend : Int.testbit (controller_pressed_value (Int.repr 128) previous) 7 = true).
 { unfold controller_pressed_value. rewrite Int.bits_zero_ext by lia. rewrite zlt_true by lia.
   rewrite Int.bits_and, Int.bits_xor by (cbn; lia).
   change (true && xorb true (Int.testbit previous 7) = true)%bool.
   rewrite Hprevious. reflexivity. }
 assert (Hstart : Int.testbit (controller_pressed_value (Int.repr 128) previous) 12 = false).
 { unfold controller_pressed_value. rewrite Int.bits_zero_ext by lia. rewrite zlt_true by lia.
   rewrite Int.bits_and, Int.bits_xor by (cbn; lia).
   change (false && xorb false (Int.testbit previous 12) = false)%bool. reflexivity. }
 pose proof (controller_mask_from_bit (controller_pressed_value (Int.repr 128) previous)
   7 true ltac:(cbn; lia) Hend) as Hendmask.
 pose proof (controller_mask_from_bit (controller_pressed_value (Int.repr 128) previous)
   12 false ltac:(cbn; lia) Hstart) as Hstartmask.
 change (Int.shl Int.one (Int.repr 7)) with (Int.repr 128) in Hendmask.
 change (Int.shl Int.one (Int.repr 12)) with (Int.repr 4096) in Hstartmask.
 cbn in Hendmask, Hstartmask. rewrite Hendmask, Hstartmask. split; reflexivity.
Qed.

Theorem controller_final_pressed_eof_guards :
 forall after controllers timer physical mask previous pressed,
 Mem.load Mint16unsigned after controllers 18 = Some (Vint
   (controller_pressed_value (playback_next_buttons timer physical mask) previous)) ->
 Mem.load Mint16unsigned after controllers 18 = Some (Vint pressed) ->
 Int.eq timer Int.zero = true -> Int.testbit previous 7 = false ->
 Int.eq (Int.and pressed (Int.repr 128)) Int.zero = false /\
 Int.eq (Int.and pressed (Int.repr 4096)) Int.zero = true.
Proof.
 intros after controllers timer physical mask previous pressed Hexpected Hactual Htimer Hprevious.
 unfold playback_next_buttons in Hexpected. rewrite Htimer in Hexpected.
 rewrite Hexpected in Hactual. inversion Hactual; subst.
 apply controller_eof_satisfies_actual_guards. exact Hprevious.
Qed.
