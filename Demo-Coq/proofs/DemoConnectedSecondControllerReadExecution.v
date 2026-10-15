From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop Ctypes
 Errors Events Floats Globalenvs Integers Maps Memdata Memory Smallstep Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoPlaybackExecution
 DemoPlaybackAdvanceExecution DemoControllerInputExecution DemoConsumedInputExecution
 DemoAnalogInputExecution DemoControllerCopyExecution DemoControllerReadExecution
 DemoPlaybackSecondControllerExecution DemoSecondControllerExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

Lemma connected_second_pad_valid : forall before pads,
 Mem.load Mint16unsigned before pads 6 = Some Vzero ->
 Mem.weak_valid_pointer before pads (Ptrofs.unsigned (Ptrofs.repr 6)) = true.
Proof.
 intros before pads Hload. change (Mem.weak_valid_pointer before pads 6 = true).
 apply Mem.valid_pointer_implies, Mem.valid_pointer_nonempty_perm.
 eapply Mem.perm_implies.
 - exact (proj1 (Mem.load_valid_access _ _ _ _ _ Hload) 6 ltac:(cbn; lia)).
 - constructor.
Qed.

Definition controller_connected_second_post_polling_demo_claim (reader runbody : function) : Prop :=
 forall (prog : Clight.program) (layout : controller_input_layout (Clight.globalenv prog)) le before
   controllers current pad stream record run analog sqrt player1 player3
   physical timer rawx rawy mask previous magnitude previous2 magnitude2 header,
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
 (forall memory, external_call controller_sqrt_external (Clight.globalenv prog)
   [Vsingle controller_zero_magnitude_argument] memory E0 (Vsingle magnitude2) memory) ->
 Float32.cmp Cgt magnitude2 (Float32.of_int (Int.repr 64)) = false ->
 controllers <> current ->
 pad <> controllers -> pad <> current -> pad <> stream ->
 stream <> controllers -> stream <> current ->
 player1 <> controllers -> player1 <> current -> player1 <> pad -> player1 <> stream ->
 player3 <> controllers -> player3 <> current -> player3 <> pad -> player3 <> stream ->
 Mem.load Mptr before controllers 24 = Some (Vptr pad Ptrofs.zero) ->
 Mem.load Mptr before controllers 52 = Some (Vptr pad (Ptrofs.repr 6)) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.valid_pointer before stream (Ptrofs.unsigned record) = true ->
 Mem.load Mint16unsigned before pad 0 = Some (Vint physical) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Mem.load Mint16unsigned before controllers 16 = Some (Vint previous) ->
 Mem.load Mint16unsigned before controllers 44 = Some (Vint previous2) ->
 Mem.load Mptr before player1 0 = Some (Vptr controllers Ptrofs.zero) ->
 Mem.load Mptr before player3 0 = Some (Vptr controllers (Ptrofs.repr 56)) ->
 Mem.load Mint32 before stream 0 = Some (Vint header) ->
 4 <= Ptrofs.unsigned record ->
 Mem.valid_access before Mint16unsigned pad 0 Writable ->
 Mem.valid_access before Mint8signed pad 2 Writable ->
 Mem.valid_access before Mint8signed pad 3 Writable ->
 Mem.valid_access before Mint8signed pad 8 Writable ->
 Mem.valid_access before Mint8signed pad 9 Writable ->
 Mem.valid_access before Mint16unsigned pad 6 Writable ->
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
 Mem.load Mint16signed after controllers 28 = Some Vzero /\
 Mem.load Mint16signed after controllers 30 = Some Vzero /\
 Mem.load Mint16unsigned after controllers 46 = Some Vzero /\
 Mem.load Mint16unsigned after controllers 44 = Some Vzero /\
 Mem.load Mfloat32 after controllers 32 = Some (Vsingle controller_float_zero) /\
 Mem.load Mfloat32 after controllers 36 = Some (Vsingle controller_float_zero) /\
 Mem.load Mfloat32 after controllers 40 = Some (Vsingle magnitude2) /\
 (forall chunk b offset value,
   Mem.load chunk before b offset = Some value ->
   playback_read_avoids chunk b offset current 0 4 ->
   playback_read_avoids chunk b offset pad 0 4 ->
   playback_read_avoids chunk b offset pad 6 10 ->
   playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record + 1) ->
   playback_read_avoids chunk b offset controllers 0 76 ->
   Mem.load chunk after b offset = Some value).

Theorem generated_controller_connected_second_post_polling_demo_executes :
  controller_connected_second_post_polling_demo_claim P.f_read_controller_inputs P.f_run_demo_inputs.
Proof.
 unfold controller_connected_second_post_polling_demo_claim.
 intros prog layout le before controllers current pad stream record run analog sqrt player1 player3
   physical timer rawx rawy mask previous magnitude previous2 magnitude2 header
   Hcontrollers Hcurrent Hrun Hfindrun Hanalog Hfindanalog Hsqrt Hfindsqrt Hplayer1 Hplayer3 Hmath Hmath2 Hbounded2
   Hcg Hpc Hpg Hps Hsc Hsg H1c H1g H1p H1s H3c H3g H3p H3s
   Hpad Hpad2 Hpointer Hvalid Hphysical Htimer Hrawx Hrawy Hmask Hprevious Hprevious2 Hpointer1 Hpointer3
   Hheader Hfirst Hwbuttons Hwx Hwy Hw2x Hw2y Hw2b Hwtimer Hwcurrent Hregion.
 pose proof (controller_region_valid_access before controllers Hregion) as Hwcontrollers.
 destruct (generated_connected_second_playback_call (Clight.globalenv prog) (input_playback_layout _ layout)
   before controllers current pad stream record physical timer rawx rawy mask
   Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
   Htimer Hrawx Hrawy Hmask Hwbuttons Hwx Hwy Hw2x Hw2y Hw2b Hwtimer Hwcurrent)
   as (played & Hplayed & Hpointer' & Htimer' & Hrawx' & Hrawy' & Hbuttons' &
     Hpad2x & Hpad2y & Hpad2b & Hplayframe & Hheader').
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
 assert (Hpad2' : Mem.load Mptr first controllers 52 = Some (Vptr pad (Ptrofs.repr 6))).
 { apply Hfirstread; [rewrite Hplayreadonly by first [assumption | apply not_eq_sym; assumption]; exact Hpad2 |
     unfold playback_read_avoids; right; right; cbn; lia]. }
 assert (Hpad2b' : Mem.load Mint16unsigned first pad 6 = Some Vzero).
 { apply Hfirstread; [exact Hpad2b | unfold playback_read_avoids; left; exact Hpc]. }
 assert (Hprevious2' : Mem.load Mint16unsigned first controllers 44 = Some (Vint previous2)).
 { apply Hfirstread; [rewrite Hplayreadonly by first [assumption | apply not_eq_sym; assumption]; exact Hprevious2 |
     unfold playback_read_avoids; right; right; vm_compute; discriminate]. }
 destruct (generated_second_connected_neutral_controller_executes_us_jp (Clight.globalenv prog) layout true
   le2 first controllers pad analog sqrt previous2 magnitude2
   ltac:(unfold le2; rewrite PTree.gss; reflexivity) ltac:(apply not_eq_sym; exact Hpc)
   Hanalog Hfindanalog Hsqrt Hfindsqrt Hmath2 Hbounded2 Hpad2'
   (connected_second_pad_valid first pad Hpad2b')
   ltac:(apply Hfirstread; [exact Hpad2x | unfold playback_read_avoids; left; exact Hpc])
   ltac:(apply Hfirstread; [exact Hpad2y | unfold playback_read_avoids; left; exact Hpc])
   Hpad2b' Hprevious2'
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]]))
   ltac:(abstract (apply Hfirstaccess, Hplayaccess; apply Hwcontrollers; [vm_compute; discriminate | vm_compute; discriminate | apply Z.mod_divide; [vm_compute; discriminate | reflexivity]])))
   as (second & le3 & Hsecondexec & Hsecondx & Hsecondy & Hsecondpressed & Hseconddown &
      Hsecondsx & Hsecondsy & Hsecondmag & Hsecondcontroller & Hsecondindex & Hsecondframe & Hsecondaccess & Hsecondvalid).
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
   + do 7 (split; [apply Hcopyread; [eassumption | unfold playback_read_avoids; right; left; vm_compute; discriminate] |]).
     intros chunk b offset value Hload Havoidcurrent Havoidpad Havoidpad2 Havoidtimer Havoidcontrollers.
     apply Hcopyread; [apply Hsecondread; [apply Hfirstread |] |].
     * rewrite Hplayframe by assumption. exact Hload.
     * eapply controller_read_avoids_subrange with (first := 0) (past := 76); [lia | lia | exact Havoidcontrollers].
     * eapply controller_read_avoids_subrange with (first := 0) (past := 76); [lia | lia | exact Havoidcontrollers].
     * eapply controller_read_avoids_subrange with (first := 0) (past := 76); [lia | lia | exact Havoidcontrollers].
Qed.

Definition demo_connected_second_controller_post_polling_claim_us_jp : Prop :=
 controller_connected_second_post_polling_demo_claim P.f_read_controller_inputs P.f_run_demo_inputs /\
 controller_connected_second_post_polling_demo_claim jp_game_init.f_read_controller_inputs jp_game_init.f_run_demo_inputs.

Theorem generated_connected_second_controller_post_polling_us_jp : demo_connected_second_controller_post_polling_claim_us_jp.
Proof. split; exact generated_controller_connected_second_post_polling_demo_executes. Qed.
