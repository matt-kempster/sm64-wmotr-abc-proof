From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
 Ctypes Errors Events Floats Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoPlaybackExecution
 DemoControllerInputExecution DemoControllerCopyExecution DemoAnalogInputExecution
 DemoControllerReadExecution DemoSecondControllerExecution DemoPhysicalPadPlaybackExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.
Theorem generated_shifted_first_copy_prefix_executes :
  forall ge (layout : controller_input_layout ge) le before
      controller pad base rawx rawy buttons previous,
    le ! P._controller = Some (Vptr controller Ptrofs.zero) ->
    controller <> pad ->
    physical_pad_base_bounds base ->
    Mem.load Mptr before controller 24 = Some (Vptr pad (Ptrofs.repr base)) ->
    Mem.load Mint8signed before pad (base+2) = Some (Vint rawx) ->
    Mem.load Mint8signed before pad (base+3) = Some (Vint rawy) ->
    Mem.load Mint16unsigned before pad base = Some (Vint buttons) ->
    Mem.load Mint16unsigned before controller 16 = Some (Vint previous) ->
    Mem.valid_access before Mint16signed controller 0 Writable ->
    Mem.valid_access before Mint16signed controller 2 Writable ->
    Mem.valid_access before Mint16unsigned controller 18 Writable ->
    Mem.valid_access before Mint16unsigned controller 16 Writable ->
    exists after le',
      exec_stmt function_entry2 ge empty_env le before
        (controller_copy_prefix (fn_body P.f_read_controller_inputs))
        E0 le' after Out_normal /\
      Mem.load Mint16signed after controller 0 = Some (Vint rawx) /\
      Mem.load Mint16signed after controller 2 = Some (Vint rawy) /\
      Mem.load Mint16unsigned after controller 18 =
        Some (Vint (controller_pressed_value buttons previous)) /\
      Mem.load Mint16unsigned after controller 16 = Some (Vint buttons) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset controller 0 4 ->
        playback_read_avoids chunk b offset controller 16 20 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      le' ! P._controller = Some (Vptr controller Ptrofs.zero) /\
      (forall chunk b offset perm,
        Mem.valid_access before chunk b offset perm ->
        Mem.valid_access after chunk b offset perm) /\
      (forall b, Mem.valid_block before b -> Mem.valid_block after b).
Proof.
  intros ge layout le before controller pad base rawx rawy buttons previous Hcontroller
    Hseparate Hbase Hpad Hrawx Hrawy Hbuttons Hprevious Hwx Hwy Hwpressed Hwdown.
  destruct layout as [layout Hraw_x Hraw_y Hstick_x Hstick_y Hstick_mag Hdown Hpressed].
  destruct layout as [controller_co pad_co record_co Hcontroller_co Hpad_co Hrecord_co
    Hcontroller_size Hdata Hbutton Hx Hy Htimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  cbn in Hraw_x, Hraw_y, Hstick_x, Hstick_y, Hstick_mag, Hdown, Hpressed.
  pose proof (Mem.load_cast _ _ _ _ _ Hrawx) as Hrawx_normal.
  pose proof (Mem.load_cast _ _ _ _ _ Hrawy) as Hrawy_normal.
  pose proof (Mem.load_cast _ _ _ _ _ Hbuttons) as Hbuttons_normal.
  cbn in Hrawx_normal, Hrawy_normal, Hbuttons_normal.
  assert (Hrawx_cast : Int.sign_ext 8 rawx = rawx) by congruence.
  assert (Hrawy_cast : Int.sign_ext 8 rawy = rawy) by congruence.
  assert (Hbuttons_cast : Int.zero_ext 16 buttons = buttons) by congruence.
  assert (Hrawx_short : Int.sign_ext 16 rawx = rawx).
  { rewrite <- Hrawx_cast at 1. rewrite Int.sign_ext_widen by lia. exact Hrawx_cast. }
  assert (Hrawy_short : Int.sign_ext 16 rawy = rawy).
  { rewrite <- Hrawy_cast at 1. rewrite Int.sign_ext_widen by lia. exact Hrawy_cast. }
  destruct (Mem.valid_access_store before Mint16signed controller 0 (Vint rawx)
    Hwx) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint16signed controller 2 (Vint rawy)
    ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint16unsigned controller 18
    (Vint (controller_pressed_value buttons previous)) ltac:(demo_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint16unsigned controller 16 (Vint buttons)
    ltac:(demo_access)) as [after Hs4].
  assert (Hpad1 : Mem.load Mptr m1 controller 24 = Some (Vptr pad (Ptrofs.repr base))) by playback_load.
  assert (Hpad2 : Mem.load Mptr m2 controller 24 = Some (Vptr pad (Ptrofs.repr base))) by playback_load.
  assert (Hpad3 : Mem.load Mptr m3 controller 24 = Some (Vptr pad (Ptrofs.repr base))) by playback_load.
  assert (Hprevious2 : Mem.load Mint16unsigned m2 controller 16 = Some (Vint previous)) by playback_load.
  assert (Hbuttons2 : Mem.load Mint16unsigned m2 pad base = Some (Vint buttons)) by playback_load.
  assert (Hbuttons3 : Mem.load Mint16unsigned m3 pad base = Some (Vint buttons)) by playback_load.
  assert (Hrawx_read1 : Mem.load Mint16signed m1 controller 0 = Some (Vint rawx)).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1).
    cbn [Val.load_result]. rewrite Hrawx_short. reflexivity. }
  assert (Hrawy_read2 : Mem.load Mint16signed m2 controller 2 = Some (Vint rawy)).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs2).
    cbn [Val.load_result]. rewrite Hrawy_short. reflexivity. }
  assert (Hpressed_read3 : Mem.load Mint16unsigned m3 controller 18 =
      Some (Vint (controller_pressed_value buttons previous))).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs3).
    unfold controller_pressed_value. cbn [Val.load_result].
    rewrite Int.zero_ext_idem by lia. reflexivity. }
  assert (Hdown_read4 : Mem.load Mint16unsigned after controller 16 = Some (Vint buttons)).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs4).
    cbn [Val.load_result]. rewrite Hbuttons_cast. reflexivity. }
  exists after. eexists. split.
  - unfold controller_copy_prefix, controller_copy_stages,
      generated_connected_controller_branch, controller_pressed_value in *.
    cbn [P.f_read_controller_inputs fn_body].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset. physical_pad_expr.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset. physical_pad_expr.
        -- physical_pad_stmt.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset. physical_pad_expr.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset. physical_pad_expr.
           ++ physical_pad_stmt.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- physical_pad_stmt.
        -- physical_pad_stmt.
  - do 4 (split; [playback_load |]). split.
    + intros chunk b offset Hraw Hbuttonrange.
      unfold playback_read_avoids in Hraw, Hbuttonrange.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by
        (destruct Hbuttonrange as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
        (destruct Hbuttonrange as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
        (destruct Hraw as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
        (destruct Hraw as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      reflexivity.
    + split.
      * cbn. repeat rewrite PTree.gsspec. cbn. exact Hcontroller.
      * split.
        -- intros chunk b offset perm Haccess.
           repeat (eapply Mem.store_valid_access_1; [eassumption |]). exact Haccess.
        -- intros b Hvalid.
           eapply Mem.store_valid_block_1; [exact Hs4 |].
           eapply Mem.store_valid_block_1; [exact Hs3 |].
           eapply Mem.store_valid_block_1; [exact Hs2 |].
           eapply Mem.store_valid_block_1; eassumption.
Qed.


Definition demo_shifted_first_controller_execution_claim (body:statement) : Prop :=
  forall ge (layout : controller_input_layout ge) le before
      controller pad base analog sqrt rawx rawy buttons previous magnitude,
    le ! P._controller = Some (Vptr controller Ptrofs.zero) ->
    controller <> pad ->
    physical_pad_base_bounds base ->
    Genv.find_symbol ge P._adjust_analog_stick = Some analog ->
    Genv.find_funct ge (Vptr analog Ptrofs.zero) = Some (Internal P.f_adjust_analog_stick) ->
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle (arbitrary_analog_square_sum rawx rawy)] m E0 (Vsingle magnitude) m) ->
    Mem.load Mptr before controller 24 = Some (Vptr pad (Ptrofs.repr base)) ->
    Mem.load Mint8signed before pad (base+2) = Some (Vint rawx) ->
    Mem.load Mint8signed before pad (base+3) = Some (Vint rawy) ->
    Mem.load Mint16unsigned before pad base = Some (Vint buttons) ->
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
        (generated_connected_controller_branch body)
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

Theorem generated_shifted_connected_arbitrary_controller_executes :
 demo_shifted_first_controller_execution_claim(fn_body P.f_read_controller_inputs).
Proof.
 unfold demo_shifted_first_controller_execution_claim.
  intros ge layout le before controller pad base analog sqrt rawx rawy buttons previous magnitude
    Hcontroller Hseparate Hbase Hanalog Hfindanalog Hsqrt Hfind Hmath Hpad
    Hrawx Hrawy Hbuttons Hprevious Hwx Hwy Hwpressed Hwdown Hwsx Hwsy Hwmag.
  destruct (generated_shifted_first_copy_prefix_executes ge layout le before
    controller pad base rawx rawy buttons previous Hcontroller Hseparate Hbase Hpad
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


Theorem generated_shifted_second_copy_prefix_executes :
  forall ge (layout : controller_input_layout ge) le before
      controller pad base rawx rawy buttons previous,
    le ! P._controller = Some (Vptr controller (Ptrofs.repr 28)) ->
    controller <> pad ->
    physical_pad_base_bounds base ->
    Mem.load Mptr before controller 52 = Some (Vptr pad (Ptrofs.repr base)) ->
    Mem.load Mint8signed before pad (base+2) = Some (Vint rawx) ->
    Mem.load Mint8signed before pad (base+3) = Some (Vint rawy) ->
    Mem.load Mint16unsigned before pad base = Some (Vint buttons) ->
    Mem.load Mint16unsigned before controller 44 = Some (Vint previous) ->
    Mem.valid_access before Mint16signed controller 28 Writable ->
    Mem.valid_access before Mint16signed controller 30 Writable ->
    Mem.valid_access before Mint16unsigned controller 46 Writable ->
    Mem.valid_access before Mint16unsigned controller 44 Writable ->
    exists after le',
      exec_stmt function_entry2 ge empty_env le before
        (controller_copy_prefix (fn_body P.f_read_controller_inputs))
        E0 le' after Out_normal /\
      Mem.load Mint16signed after controller 28 = Some (Vint rawx) /\
      Mem.load Mint16signed after controller 30 = Some (Vint rawy) /\
      Mem.load Mint16unsigned after controller 46 =
        Some (Vint (controller_pressed_value buttons previous)) /\
      Mem.load Mint16unsigned after controller 44 = Some (Vint buttons) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset controller 28 32 ->
        playback_read_avoids chunk b offset controller 44 48 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      le' ! P._controller = Some (Vptr controller (Ptrofs.repr 28)) /\
      le' ! P._i = le ! P._i /\
      (forall chunk b offset perm,
        Mem.valid_access before chunk b offset perm ->
        Mem.valid_access after chunk b offset perm) /\
      (forall b, Mem.valid_block before b -> Mem.valid_block after b) /\
      Mem.unchanged_on (controller_outside_bytes controller 28 48) before after.
Proof.
  intros ge layout le before controller pad base rawx rawy buttons previous Hcontroller
    Hseparate Hbase Hpad Hrawx Hrawy Hbuttons Hprevious Hwx Hwy Hwpressed Hwdown.
  destruct layout as [layout Hraw_x Hraw_y Hstick_x Hstick_y Hstick_mag Hdown Hpressed].
  destruct layout as [controller_co pad_co record_co Hcontroller_co Hpad_co Hrecord_co
    Hcontroller_size Hdata Hbutton Hx Hy Htimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  cbn in Hraw_x, Hraw_y, Hstick_x, Hstick_y, Hstick_mag, Hdown, Hpressed.
  pose proof (Mem.load_cast _ _ _ _ _ Hrawx) as Hrawx_normal.
  pose proof (Mem.load_cast _ _ _ _ _ Hrawy) as Hrawy_normal.
  pose proof (Mem.load_cast _ _ _ _ _ Hbuttons) as Hbuttons_normal.
  cbn in Hrawx_normal, Hrawy_normal, Hbuttons_normal.
  assert (Hrawx_cast : Int.sign_ext 8 rawx = rawx) by congruence.
  assert (Hrawy_cast : Int.sign_ext 8 rawy = rawy) by congruence.
  assert (Hbuttons_cast : Int.zero_ext 16 buttons = buttons) by congruence.
  assert (Hrawx_short : Int.sign_ext 16 rawx = rawx).
  { rewrite <- Hrawx_cast at 1. rewrite Int.sign_ext_widen by lia. exact Hrawx_cast. }
  assert (Hrawy_short : Int.sign_ext 16 rawy = rawy).
  { rewrite <- Hrawy_cast at 1. rewrite Int.sign_ext_widen by lia. exact Hrawy_cast. }
  destruct (Mem.valid_access_store before Mint16signed controller 28 (Vint rawx)
    Hwx) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint16signed controller 30 (Vint rawy)
    ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint16unsigned controller 46
    (Vint (controller_pressed_value buttons previous)) ltac:(demo_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint16unsigned controller 44 (Vint buttons)
    ltac:(demo_access)) as [after Hs4].
  assert (Hpad1 : Mem.load Mptr m1 controller 52 = Some (Vptr pad (Ptrofs.repr base))) by controller_copy_load.
  assert (Hpad2 : Mem.load Mptr m2 controller 52 = Some (Vptr pad (Ptrofs.repr base))) by controller_copy_load.
  assert (Hpad3 : Mem.load Mptr m3 controller 52 = Some (Vptr pad (Ptrofs.repr base))) by controller_copy_load.
  assert (Hprevious2 : Mem.load Mint16unsigned m2 controller 44 = Some (Vint previous)) by controller_copy_load.
  assert (Hbuttons2 : Mem.load Mint16unsigned m2 pad base = Some (Vint buttons)) by controller_copy_load.
  assert (Hbuttons3 : Mem.load Mint16unsigned m3 pad base = Some (Vint buttons)) by controller_copy_load.
  assert (Hrawx_read1 : Mem.load Mint16signed m1 controller 28 = Some (Vint rawx)).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1).
    cbn [Val.load_result]. rewrite Hrawx_short. reflexivity. }
  assert (Hrawy_read2 : Mem.load Mint16signed m2 controller 30 = Some (Vint rawy)).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs2).
    cbn [Val.load_result]. rewrite Hrawy_short. reflexivity. }
  assert (Hpressed_read3 : Mem.load Mint16unsigned m3 controller 46 =
      Some (Vint (controller_pressed_value buttons previous))).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs3).
    unfold controller_pressed_value. cbn [Val.load_result].
    rewrite Int.zero_ext_idem by lia. reflexivity. }
  assert (Hdown_read4 : Mem.load Mint16unsigned after controller 44 = Some (Vint buttons)).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs4).
    cbn [Val.load_result]. rewrite Hbuttons_cast. reflexivity. }
  exists after. eexists. split.
  - unfold controller_copy_prefix, controller_copy_stages,
      generated_connected_controller_branch, controller_pressed_value in *.
    cbn [P.f_read_controller_inputs fn_body].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset. physical_pad_expr.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset. physical_pad_expr.
        -- physical_pad_stmt.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset. physical_pad_expr.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset. physical_pad_expr.
           ++ physical_pad_stmt.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- physical_pad_stmt.
        -- physical_pad_stmt.
  - do 4 (split; [controller_copy_load |]). split.
    + intros chunk b offset Hraw Hbuttonrange.
      unfold playback_read_avoids in Hraw, Hbuttonrange.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by
        (destruct Hbuttonrange as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
        (destruct Hbuttonrange as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
        (destruct Hraw as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
        (destruct Hraw as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      reflexivity.
    + split.
      * cbn. repeat rewrite PTree.gsspec. cbn. exact Hcontroller.
      * split; [cbn; repeat rewrite PTree.gsspec; reflexivity |].
        split.
        -- intros chunk b offset perm Haccess.
           repeat (eapply Mem.store_valid_access_1; [eassumption |]). exact Haccess.
        -- split.
           ++ intros b Hvalid.
              eapply Mem.store_valid_block_1; [exact Hs4 |].
              eapply Mem.store_valid_block_1; [exact Hs3 |].
              eapply Mem.store_valid_block_1; [exact Hs2 |].
              eapply Mem.store_valid_block_1; eassumption.
           ++ controller_copy_frame.
Qed.


Definition demo_shifted_second_controller_execution_claim : Prop :=
 forall ge (layout:controller_input_layout ge) (us:bool) le before
   controllers pads base analog sqrt previous magnitude,
 le ! P._controller = Some (Vptr controllers (Ptrofs.repr 28)) ->
 controllers <> pads ->
 physical_pad_base_bounds base ->
 Genv.find_symbol ge P._adjust_analog_stick = Some analog ->
 Genv.find_funct ge (Vptr analog Ptrofs.zero) = Some (Internal P.f_adjust_analog_stick) ->
 Genv.find_symbol ge P._sqrtf = Some sqrt ->
 Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
 (forall m, external_call controller_sqrt_external ge
   [Vsingle controller_zero_magnitude_argument] m E0 (Vsingle magnitude) m) ->
 Float32.cmp Cgt magnitude (Float32.of_int (Int.repr 64)) = false ->
 Mem.load Mptr before controllers 52 = Some (Vptr pads (Ptrofs.repr base)) ->
 Mem.weak_valid_pointer before pads (Ptrofs.unsigned (Ptrofs.repr base)) = true ->
 Mem.load Mint8signed before pads (base+2) = Some Vzero ->
 Mem.load Mint8signed before pads (base+3) = Some Vzero ->
 Mem.load Mint16unsigned before pads base = Some Vzero ->
 Mem.load Mint16unsigned before controllers 44 = Some (Vint previous) ->
 Mem.valid_access before Mint16signed controllers 28 Writable ->
 Mem.valid_access before Mint16signed controllers 30 Writable ->
 Mem.valid_access before Mint16unsigned controllers 46 Writable ->
 Mem.valid_access before Mint16unsigned controllers 44 Writable ->
 Mem.valid_access before Mfloat32 controllers 32 Writable ->
 Mem.valid_access before Mfloat32 controllers 36 Writable ->
 Mem.valid_access before Mfloat32 controllers 40 Writable ->
 exists after le',
  exec_stmt function_entry2 ge empty_env le before
   (controller_data_decision (fn_body
     (if us then P.f_read_controller_inputs else jp_game_init.f_read_controller_inputs)))
   E0 le' after Out_normal /\
  Mem.load Mint16signed after controllers 28 = Some Vzero /\
  Mem.load Mint16signed after controllers 30 = Some Vzero /\
  Mem.load Mint16unsigned after controllers 46 = Some Vzero /\
  Mem.load Mint16unsigned after controllers 44 = Some Vzero /\
  Mem.load Mfloat32 after controllers 32 = Some (Vsingle controller_float_zero) /\
  Mem.load Mfloat32 after controllers 36 = Some (Vsingle controller_float_zero) /\
  Mem.load Mfloat32 after controllers 40 = Some (Vsingle magnitude) /\
  le' ! P._controller = le ! P._controller /\
  le' ! P._i = le ! P._i /\
  Mem.unchanged_on (controller_outside_bytes controllers 28 48) before after /\
  (forall chunk b offset permission, Mem.valid_access before chunk b offset permission ->
    Mem.valid_access after chunk b offset permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b).

Theorem generated_shifted_second_connected_neutral_controller_executes_us_jp :
 demo_shifted_second_controller_execution_claim.
Proof.
 intros ge layout us le before controllers pads base analog sqrt previous magnitude Hcontroller Hseparate Hbase
   Hanalog Hfindanalog Hsqrt Hfind Hmath Hbounded Hpad Hvalidpad Hrawx Hrawy Hbuttons Hprevious
   Hwx Hwy Hwpressed Hwdown Hwsx Hwsy Hwmag.
 set (guarded:=PTree.set P._t'22 (Vptr pads (Ptrofs.repr base)) le).
 assert (Hguarded_controller : guarded ! P._controller = Some (Vptr controllers (Ptrofs.repr 28))).
 { unfold guarded. rewrite PTree.gso by discriminate. exact Hcontroller. }
 destruct (generated_shifted_second_copy_prefix_executes ge layout guarded before
   controllers pads base Int.zero Int.zero Int.zero previous Hguarded_controller Hseparate Hbase Hpad
   Hrawx Hrawy Hbuttons Hprevious Hwx Hwy Hwpressed Hwdown)
   as (copied & lec & Hprefix & Hrawx' & Hrawy' & Hpressed & Hdown & Hcopyframe &
     Hcontroller' & Hindex' & Hcopyaccess & Hcopyvalid & Hcopybytes).
 rewrite second_controller_neutral_pressed in Hpressed.
 destruct (generated_second_neutral_analog_call_executes ge layout copied controllers
   sqrt magnitude Hsqrt Hfind Hmath Hbounded Hrawx' Hrawy'
   (Hcopyaccess _ _ _ _ Hwsx) (Hcopyaccess _ _ _ _ Hwsy) (Hcopyaccess _ _ _ _ Hwmag))
   as (after & Hcall & Hsx & Hsy & Hmag & Hanalogframe & Hanalogperm & Hanalogaccess & Hanalogbytes).
 assert (Hanalog_stmt : exec_stmt function_entry2 ge empty_env lec copied
   (let '(_,_,_,_,analog):=controller_copy_stages (fn_body P.f_read_controller_inputs) in analog)
   E0 lec after Out_normal).
 { cbn [controller_copy_stages generated_connected_controller_branch P.f_read_controller_inputs fn_body].
   eapply exec_Scall with (vargs:=[Vptr controllers (Ptrofs.repr 28)]) (vres:=Vundef);
     [reflexivity|second_expr|second_arguments|exact Hfindanalog|reflexivity|exact Hcall]. }
 assert (Hbranch := controller_prefix_then_analog ge guarded before copied lec after lec Hprefix Hanalog_stmt).
 assert (Hvalidcontroller : Mem.valid_block copied controllers).
 { eapply Mem.valid_access_valid_block. eapply Mem.valid_access_implies.
   - eapply Mem.load_valid_access. exact Hrawx'.
   - constructor. }
 assert (Hallbytes : Mem.unchanged_on (controller_outside_bytes controllers 28 48) before after).
 { eapply Mem.unchanged_on_trans; [exact Hcopybytes|].
   eapply Mem.unchanged_on_implies; [exact Hanalogbytes|].
   unfold controller_outside_bytes. intros b byte Houtside Hvb.
   destruct Houtside as [Hd|[Hb|Ha]]; first [left;exact Hd|right;left;lia|right;right;lia]. }
 exists after, lec. split.
 - assert (Hselected : controller_data_decision (fn_body
       (if us then P.f_read_controller_inputs else jp_game_init.f_read_controller_inputs)) =
       controller_data_decision (fn_body P.f_read_controller_inputs)) by (destruct us;reflexivity).
   rewrite Hselected. cbn [controller_data_decision P.f_read_controller_inputs fn_body].
   eapply exec_Sseq_1 with (t1:=E0) (t2:=E0) (le1:=guarded) (m1:=before).
   + unfold guarded. eapply exec_Sset.
     destruct layout as [layout Hrx Hry Hsxoff Hsyoff Hsmoff Hdownoff Hpressedoff].
     destruct layout. cbn in *. physical_pad_expr.
   + eapply exec_Sifthenelse with (v1:=Vint Int.one) (b:=true).
     * eapply eval_Ebinop with (v1:=Vptr pads (Ptrofs.repr base)) (v2:=Vzero).
       -- eapply eval_Etempvar. unfold guarded. apply PTree.gss.
       -- eapply eval_Ecast; [constructor|reflexivity].
       -- change (option_map Val.of_bool
            (if Mem.weak_valid_pointer before pads (Ptrofs.unsigned (Ptrofs.repr base))
             then Some true else None) = Some (Vint Int.one)).
          rewrite Hvalidpad. reflexivity.
     * reflexivity.
     * exact Hbranch.
 - do 4 (split; [rewrite Hanalogframe by
     (try exact Hvalidcontroller; unfold playback_read_avoids;
      first [right;left;cbn;lia|right;right;cbn;lia]); eassumption|]).
   split;[exact Hsx|]. split;[exact Hsy|]. split;[exact Hmag|].
   split;[rewrite Hcontroller';symmetry;exact Hcontroller|].
   split;[rewrite Hindex';unfold guarded;apply PTree.gso;discriminate|].
   split;[exact Hallbytes|]. split.
   + intros chunk b offset permission Haccess. apply Hanalogaccess,Hcopyaccess,Haccess.
   + intros b Hvalid. eapply Mem.valid_block_unchanged_on; eassumption.
Qed.

Definition demo_shifted_controller_execution_claim : Prop :=
 demo_shifted_first_controller_execution_claim(fn_body P.f_read_controller_inputs) /\
 demo_shifted_first_controller_execution_claim(fn_body jp_game_init.f_read_controller_inputs) /\
 demo_shifted_second_controller_execution_claim.

Theorem generated_shifted_controller_execution_us_jp : demo_shifted_controller_execution_claim.
Proof.
 split;[exact generated_shifted_connected_arbitrary_controller_executes|].
 split;[exact generated_shifted_connected_arbitrary_controller_executes|
   exact generated_shifted_second_connected_neutral_controller_executes_us_jp].
Qed.
