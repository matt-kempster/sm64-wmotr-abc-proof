From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution DemoPlaybackExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

Definition playback_advance (record : ptrofs) : ptrofs :=
  Ptrofs.add record (Ptrofs.repr 4).

Ltac playback_normalize ::=
  first
  [match goal with
   | H : Int.eq ?x ?y = ?flag |- _ = ?out =>
       change (Some (Val.of_bool (Int.eq x y)) = out); rewrite H; reflexivity
   end
  |cbn -[Int.sign_ext Int.zero_ext Int.repr Ptrofs.repr Ptrofs.add Ptrofs.mul Ptrofs.of_ints];
   repeat match goal with
   | H : (genv_cenv ?ge) ! ?id = Some ?co |-
       context [match (genv_cenv ?ge) ! ?id with _ => _ end] => rewrite H
   | H : co_sizeof ?co = _ |- context [co_sizeof ?co] => rewrite H
   end;
   cbn -[Int.sign_ext Int.zero_ext Int.repr];
   repeat match goal with
   | H : Int.sign_ext ?bits ?value = ?value |- context [Int.sign_ext ?bits ?value] => rewrite H
   | H : Int.zero_ext ?bits ?value = ?value |- context [Int.zero_ext ?bits ?value] => rewrite H
   end;
   repeat rewrite Int.zero_ext_idem by lia;
   repeat rewrite Int.sign_ext_idem by lia;
   repeat rewrite Ptrofs.add_zero;
   first [reflexivity | eapply demo_valid_nonnull_pointer_comparison; eassumption]].

Theorem generated_playback_advancing_record_body :
  forall (ge : Clight.genv) (layout : playback_layout ge) le before
      controllers current pad stream record physical timer rawx rawy mask,
    Genv.find_symbol ge P._gControllers = Some controllers ->
    Genv.find_symbol ge P._gCurrDemoInput = Some current ->
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
    Int.eq timer Int.zero = false ->
    Int.eq (playback_decrement timer) Int.zero = true ->
    Mem.valid_access before Mint16unsigned pad 0 Writable ->
    Mem.valid_access before Mint8signed pad 2 Writable ->
    Mem.valid_access before Mint8signed pad 3 Writable ->
    Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
    Mem.valid_access before Mptr current 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge empty_env le before
        (fn_body P.f_run_demo_inputs) E0 le' after Out_normal /\
      Mem.load Mptr after current 0 = Some (Vptr stream (playback_advance record)) /\
      Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer)) /\
      Mem.load Mint8signed after pad 2 = Some (Vint rawx) /\
      Mem.load Mint8signed after pad 3 = Some (Vint rawy) /\
      Mem.load Mint16unsigned after pad 0 = Some (Vint (playback_output_buttons physical mask)) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset current 0 4 ->
        playback_read_avoids chunk b offset pad 0 4 ->
        playback_read_avoids chunk b offset stream (Ptrofs.unsigned record)
          (Ptrofs.unsigned record + 1) ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
  intros ge layout le before controllers current pad stream record physical timer rawx rawy mask
    Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
    Htimer Hrawx Hrawy Hmask Hpositive Hlast Hwbuttons Hwx Hwy Hwtimer Hwcurrent.
  destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
    Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  pose proof (Mem.load_cast _ _ _ _ _ Hrawx) as Hrawx_normal.
  pose proof (Mem.load_cast _ _ _ _ _ Hrawy) as Hrawy_normal.
  cbn in Hrawx_normal, Hrawy_normal.
  assert (Hrawx_cast : Int.sign_ext 8 rawx = rawx) by congruence.
  assert (Hrawy_cast : Int.sign_ext 8 rawy = rawy) by congruence.
  destruct (Mem.valid_access_store before Mint16unsigned pad 0
    (Vint (playback_masked_buttons physical)) Hwbuttons) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint8signed pad 2 (Vint rawx)
    ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint8signed pad 3 (Vint rawy)
    ltac:(demo_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint16unsigned pad 0
    (Vint (playback_record_buttons_value mask)) ltac:(demo_access)) as [m4 Hs4].
  destruct (Mem.valid_access_store m4 Mint16unsigned pad 0
    (Vint (playback_output_buttons physical mask)) ltac:(demo_access)) as [m5 Hs5].
  destruct (Mem.valid_access_store m5 Mint8unsigned stream (Ptrofs.unsigned record)
    (Vint (playback_decrement timer)) ltac:(demo_access)) as [m6 Hs6].
  destruct (Mem.valid_access_store m6 Mptr current 0
    (Vptr stream (playback_advance record)) ltac:(demo_access)) as [after Hs7].
  assert (Hvalid1 : Mem.valid_pointer m1 stream (Ptrofs.unsigned record) = true).
  { apply Mem.valid_pointer_nonempty_perm. eapply Mem.perm_store_1; [exact Hs1 |].
    apply Mem.valid_pointer_nonempty_perm. exact Hvalid. }
  assert (Hmasked_read : Mem.load Mint16unsigned m1 pad 0 =
    Some (Vint (playback_masked_buttons physical))).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1).
    unfold playback_masked_buttons. cbn [Val.load_result].
    rewrite Int.zero_ext_idem by lia. reflexivity. }
  assert (Hrawx_read : Mem.load Mint8signed m2 pad 2 = Some (Vint rawx)).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs2).
    cbn [Val.load_result]. rewrite Hrawx_cast. reflexivity. }
  assert (Hrawy_read : Mem.load Mint8signed m3 pad 3 = Some (Vint rawy)).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs3).
    cbn [Val.load_result]. rewrite Hrawy_cast. reflexivity. }
  assert (Hdecoded_read : Mem.load Mint16unsigned m4 pad 0 =
    Some (Vint (playback_record_buttons_value mask))).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs4).
    unfold playback_record_buttons_value. cbn [Val.load_result].
    rewrite Int.zero_ext_idem by lia. reflexivity. }
  assert (Houtput_read : Mem.load Mint16unsigned m5 pad 0 =
    Some (Vint (playback_output_buttons physical mask))).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs5).
    unfold playback_output_buttons. cbn [Val.load_result].
    rewrite Int.zero_ext_idem by lia. reflexivity. }
  assert (Hdecrement_read : Mem.load Mint8unsigned m6 stream
    (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer))).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs6).
    unfold playback_decrement. cbn [Val.load_result].
    rewrite Int.zero_ext_idem by lia. reflexivity. }
  exists after. eexists. split.
  - unfold playback_advance in Hs7.
    unfold playback_field_offset in Hrawx, Hrawy, Hmask.
    unfold playback_masked_buttons, playback_record_buttons_value,
      playback_output_buttons, playback_start_button, playback_decrement in *.
    cbn [P.f_run_demo_inputs fn_body].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset. playback_expr.
      * playback_stmt.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset. playback_expr.
      * eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
        -- playback_expr.
        -- reflexivity.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ playback_stmt.
           ++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
              ** eapply exec_Sset. playback_expr.
              ** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                 --- eapply exec_Sset. playback_expr.
                 --- eapply exec_Sifthenelse with (v1 := Vzero) (b := false).
                     +++ playback_expr.
                     +++ reflexivity.
                     +++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                         *** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                             ---- eapply exec_Sset. playback_expr.
                             ---- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                                  ++++ eapply exec_Sset. playback_expr.
                                  ++++ eapply exec_Sset. playback_expr.
                         *** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                             ---- playback_stmt.
                             ---- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                                  ++++ playback_stmt.
                                  ++++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                                       ***** playback_stmt.
                                       ***** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                                             ----- playback_stmt.
                                             ----- playback_stmt.
  - repeat split.
    + playback_load.
    + unfold playback_decrement. playback_load.
    + playback_load.
    + playback_load.
    + unfold playback_output_buttons, playback_record_buttons_value,
        playback_start_button, playback_masked_buttons. playback_load.
    + intros chunk b offset Hbg Hbp Hbs.
      unfold playback_read_avoids in Hbg, Hbp, Hbs.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs7) by
        (destruct Hbg as [H | [H | H]]; [left; exact H | right; left; exact H | right; right; exact H]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs6) by
        (destruct Hbs as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs5) by
        (destruct Hbp as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by
        (destruct Hbp as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
        (destruct Hbp as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
        (destruct Hbp as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
        (destruct Hbp as [H | [H | H]];
          first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
      reflexivity.
Qed.

(** The zero timer is the actual EOF sentinel: the code produces END_DEMO,
    clears both sticks, and leaves the input pointer and stream untouched. *)
Theorem generated_playback_eof_body :
  forall (ge : Clight.genv) (layout : playback_layout ge) le before
      controllers current pad stream record physical,
    Genv.find_symbol ge P._gControllers = Some controllers ->
    Genv.find_symbol ge P._gCurrDemoInput = Some current ->
    pad <> controllers -> pad <> current -> pad <> stream ->
    Mem.load Mptr before controllers 24 = Some (Vptr pad Ptrofs.zero) ->
    Mem.load Mptr before controllers 52 = Some Vzero ->
    Mem.load Mptr before current 0 = Some (Vptr stream record) ->
    Mem.valid_pointer before stream (Ptrofs.unsigned record) = true ->
    Mem.load Mint16unsigned before pad 0 = Some (Vint physical) ->
    Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some Vzero ->
    Mem.valid_access before Mint16unsigned pad 0 Writable ->
    Mem.valid_access before Mint8signed pad 2 Writable ->
    Mem.valid_access before Mint8signed pad 3 Writable ->
    exists after le',
      exec_stmt function_entry2 ge empty_env le before
        (fn_body P.f_run_demo_inputs) E0 le' after Out_normal /\
      Mem.load Mptr after current 0 = Some (Vptr stream record) /\
      Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some Vzero /\
      Mem.load Mint8signed after pad 2 = Some Vzero /\
      Mem.load Mint8signed after pad 3 = Some Vzero /\
      Mem.load Mint16unsigned after pad 0 = Some (Vint (Int.repr 128)) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset pad 0 4 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
  intros ge layout le before controllers current pad stream record physical
    Hcontrollers Hcurrent Hpc Hpg Hps Hpad Hpad2 Hpointer Hvalid Hphysical
    Htimer Hwbuttons Hwx Hwy.
  destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
    Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  destruct (Mem.valid_access_store before Mint16unsigned pad 0
    (Vint (playback_masked_buttons physical)) Hwbuttons) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint8signed pad 2 Vzero
    ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint8signed pad 3 Vzero
    ltac:(demo_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint16unsigned pad 0 (Vint (Int.repr 128))
    ltac:(demo_access)) as [after Hs4].
  assert (Hvalid1 : Mem.valid_pointer m1 stream (Ptrofs.unsigned record) = true).
  { apply Mem.valid_pointer_nonempty_perm. eapply Mem.perm_store_1; [exact Hs1 |].
    apply Mem.valid_pointer_nonempty_perm. exact Hvalid. }
  exists after. eexists. split.
  - unfold playback_masked_buttons in Hs1.
    cbn [P.f_run_demo_inputs fn_body]. playback_stmt.
  - repeat split; try playback_load.
    intros chunk b offset Hbp. unfold playback_read_avoids in Hbp.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by
      (destruct Hbp as [H | [H | H]];
        first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
      (destruct Hbp as [H | [H | H]];
        first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
      (destruct Hbp as [H | [H | H]];
        first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
      (destruct Hbp as [H | [H | H]];
        first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
    reflexivity.
Qed.

Definition demo_playback_eof_call_claim (f : function) : Prop :=
  forall (ge : Clight.genv) (layout : playback_layout ge) before
      controllers current pad stream record physical,
    Genv.find_symbol ge P._gControllers = Some controllers ->
    Genv.find_symbol ge P._gCurrDemoInput = Some current ->
    pad <> controllers -> pad <> current -> pad <> stream ->
    Mem.load Mptr before controllers 24 = Some (Vptr pad Ptrofs.zero) ->
    Mem.load Mptr before controllers 52 = Some Vzero ->
    Mem.load Mptr before current 0 = Some (Vptr stream record) ->
    Mem.valid_pointer before stream (Ptrofs.unsigned record) = true ->
    Mem.load Mint16unsigned before pad 0 = Some (Vint physical) ->
    Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some Vzero ->
    Mem.valid_access before Mint16unsigned pad 0 Writable ->
    Mem.valid_access before Mint8signed pad 2 Writable ->
    Mem.valid_access before Mint8signed pad 3 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef /\
      Mem.load Mptr after current 0 = Some (Vptr stream record) /\
      Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some Vzero /\
      Mem.load Mint8signed after pad 2 = Some Vzero /\
      Mem.load Mint8signed after pad 3 = Some Vzero /\
      Mem.load Mint16unsigned after pad 0 = Some (Vint (Int.repr 128)) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset pad 0 4 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).

Theorem generated_playback_eof_call :
  demo_playback_eof_call_claim P.f_run_demo_inputs.
Proof.
  unfold demo_playback_eof_call_claim.
  intros ge layout before controllers current pad stream record physical
    Hcontrollers Hcurrent Hpc Hpg Hps Hpad Hpad2 Hpointer Hvalid Hphysical
    Htimer Hwbuttons Hwx Hwy.
  destruct (generated_playback_eof_body ge layout
    (create_undef_temps (fn_temps P.f_run_demo_inputs)) before controllers current
    pad stream record physical Hcontrollers Hcurrent Hpc Hpg Hps Hpad Hpad2
    Hpointer Hvalid Hphysical Htimer Hwbuttons Hwx Hwy)
    as (after & le' & Hbody & Hrest).
  exists after. split; [|exact Hrest].
  eapply eval_funcall_internal with (e := empty_env)
    (le1 := create_undef_temps (fn_temps P.f_run_demo_inputs))
    (le2 := le') (m1 := before) (m2 := after) (out := Out_normal).
  - constructor.
    + constructor.
    + constructor.
    + unfold list_disjoint. cbn. tauto.
    + constructor.
    + reflexivity.
  - exact Hbody.
  - reflexivity.
  - reflexivity.
Qed.

Definition demo_playback_advancing_record_call_claim (f : function) : Prop :=
  forall (ge : Clight.genv) (layout : playback_layout ge) before
      controllers current pad stream record physical timer rawx rawy mask,
    Genv.find_symbol ge P._gControllers = Some controllers ->
    Genv.find_symbol ge P._gCurrDemoInput = Some current ->
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
    Int.eq timer Int.zero = false ->
    Int.eq (playback_decrement timer) Int.zero = true ->
    Mem.valid_access before Mint16unsigned pad 0 Writable ->
    Mem.valid_access before Mint8signed pad 2 Writable ->
    Mem.valid_access before Mint8signed pad 3 Writable ->
    Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
    Mem.valid_access before Mptr current 0 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef /\
      Mem.load Mptr after current 0 = Some (Vptr stream (playback_advance record)) /\
      Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer)) /\
      Mem.load Mint8signed after pad 2 = Some (Vint rawx) /\
      Mem.load Mint8signed after pad 3 = Some (Vint rawy) /\
      Mem.load Mint16unsigned after pad 0 = Some (Vint (playback_output_buttons physical mask)) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset current 0 4 ->
        playback_read_avoids chunk b offset pad 0 4 ->
        playback_read_avoids chunk b offset stream (Ptrofs.unsigned record)
          (Ptrofs.unsigned record + 1) ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).

Theorem generated_playback_advancing_record_call :
  demo_playback_advancing_record_call_claim P.f_run_demo_inputs.
Proof.
  unfold demo_playback_advancing_record_call_claim.
  intros ge layout before controllers current pad stream record physical timer rawx rawy mask
    Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
    Htimer Hrawx Hrawy Hmask Hpositive Hlast Hwbuttons Hwx Hwy Hwtimer Hwcurrent.
  destruct (generated_playback_advancing_record_body ge layout
    (create_undef_temps (fn_temps P.f_run_demo_inputs)) before controllers current
    pad stream record physical timer rawx rawy mask Hcontrollers Hcurrent Hpc Hpg
    Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical Htimer Hrawx Hrawy Hmask
    Hpositive Hlast Hwbuttons Hwx Hwy Hwtimer Hwcurrent)
    as (after & le' & Hbody & Hrest).
  exists after. split; [|exact Hrest].
  eapply eval_funcall_internal with (e := empty_env)
    (le1 := create_undef_temps (fn_temps P.f_run_demo_inputs))
    (le2 := le') (m1 := before) (m2 := after) (out := Out_normal).
  - constructor.
    + constructor.
    + constructor.
    + unfold list_disjoint. cbn. tauto.
    + constructor.
    + reflexivity.
  - exact Hbody.
  - reflexivity.
  - reflexivity.
Qed.

Definition playback_next_record (timer : int) (record : ptrofs) : ptrofs :=
  if Int.eq timer Int.zero then record
  else if Int.eq (playback_decrement timer) Int.zero
       then playback_advance record else record.

Definition playback_next_timer (timer : int) : int :=
  if Int.eq timer Int.zero then Int.zero else playback_decrement timer.

Definition playback_next_stick (timer recorded : int) : int :=
  if Int.eq timer Int.zero then Int.zero else recorded.

Definition playback_next_buttons (timer physical mask : int) : int :=
  if Int.eq timer Int.zero then Int.repr 128
  else playback_output_buttons physical mask.

Lemma playback_advance_no_wrap :
  forall record bytes,
    4 <= Ptrofs.unsigned record ->
    Ptrofs.unsigned record + 8 <= bytes ->
    bytes <= Ptrofs.max_unsigned ->
    Ptrofs.unsigned (playback_advance record) = Ptrofs.unsigned record + 4 /\
    4 <= Ptrofs.unsigned (playback_advance record) /\
    Ptrofs.unsigned (playback_advance record) + 4 <= bytes.
Proof.
  intros record bytes Hfirst Hnext Hmax.
  unfold playback_advance. rewrite Ptrofs.add_unsigned.
  change (Ptrofs.unsigned (Ptrofs.repr 4)) with 4.
  rewrite Ptrofs.unsigned_repr by lia. repeat split; lia.
Qed.

Definition playback_buffer_bounds_claim : Prop :=
  forall record bytes timer,
    4 <= Ptrofs.unsigned record ->
    Ptrofs.unsigned record + 8 <= bytes ->
    bytes <= Ptrofs.max_unsigned ->
    4 <= Ptrofs.unsigned (playback_next_record timer record) /\
    Ptrofs.unsigned (playback_next_record timer record) + 4 <= bytes.

Theorem playback_next_record_stays_in_buffer : playback_buffer_bounds_claim.
Proof.
  unfold playback_buffer_bounds_claim, playback_next_record.
  intros record bytes timer Hfirst Hnext Hmax.
  destruct (Int.eq timer Int.zero); [split; lia |].
  destruct (Int.eq (playback_decrement timer) Int.zero); [|split; lia].
  destruct (playback_advance_no_wrap record bytes Hfirst Hnext Hmax)
    as [Hexact [Hlower Hupper]]. split; assumption.
Qed.

Lemma playback_byte_frame_preserves_header :
  forall before after current pad stream record,
    pad <> stream -> current <> stream -> 4 <= Ptrofs.unsigned record ->
    (forall chunk b offset,
      playback_read_avoids chunk b offset current 0 4 ->
      playback_read_avoids chunk b offset pad 0 4 ->
      playback_read_avoids chunk b offset stream (Ptrofs.unsigned record)
        (Ptrofs.unsigned record + 1) ->
      Mem.load chunk after b offset = Mem.load chunk before b offset) ->
    Mem.load Mint32 after stream 0 = Mem.load Mint32 before stream 0.
Proof.
  intros before after current pad stream record Hps Hgs Hfirst Hframe.
  apply Hframe; unfold playback_read_avoids.
  - left. congruence.
  - left. congruence.
  - right. left. cbn. exact Hfirst.
Qed.

(** The three timer cases exhaust the complete generated consumer.  The
    common memory premises also supply fields that EOF does not read. *)
Definition demo_playback_all_timers_call_claim (f : function) : Prop :=
  forall (ge : Clight.genv) (layout : playback_layout ge) before
      controllers current pad stream record physical timer rawx rawy mask,
    Genv.find_symbol ge P._gControllers = Some controllers ->
    Genv.find_symbol ge P._gCurrDemoInput = Some current ->
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
    Mem.valid_access before Mint16unsigned pad 0 Writable ->
    Mem.valid_access before Mint8signed pad 2 Writable ->
    Mem.valid_access before Mint8signed pad 3 Writable ->
    Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
    Mem.valid_access before Mptr current 0 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef /\
      Mem.load Mptr after current 0 = Some (Vptr stream (playback_next_record timer record)) /\
      Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_next_timer timer)) /\
      Mem.load Mint8signed after pad 2 = Some (Vint (playback_next_stick timer rawx)) /\
      Mem.load Mint8signed after pad 3 = Some (Vint (playback_next_stick timer rawy)) /\
      Mem.load Mint16unsigned after pad 0 = Some (Vint (playback_next_buttons timer physical mask)) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset current 0 4 ->
        playback_read_avoids chunk b offset pad 0 4 ->
        playback_read_avoids chunk b offset stream (Ptrofs.unsigned record)
          (Ptrofs.unsigned record + 1) ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      (4 <= Ptrofs.unsigned record ->
        Mem.load Mint32 after stream 0 = Mem.load Mint32 before stream 0).

Theorem generated_playback_all_timers_call :
  demo_playback_all_timers_call_claim P.f_run_demo_inputs.
Proof.
  unfold demo_playback_all_timers_call_claim.
  intros ge layout before controllers current pad stream record physical timer rawx rawy mask
    Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
    Htimer Hrawx Hrawy Hmask Hwbuttons Hwx Hwy Hwtimer Hwcurrent.
  unfold playback_next_record, playback_next_timer, playback_next_stick,
    playback_next_buttons.
  destruct (Int.eq timer Int.zero) eqn:Hzero.
  - pose proof (Int.eq_spec timer Int.zero) as Hequal.
    rewrite Hzero in Hequal. subst timer.
    destruct (generated_playback_eof_call ge layout before controllers current
      pad stream record physical Hcontrollers Hcurrent Hpc Hpg Hps Hpad Hpad2
      Hpointer Hvalid Hphysical Htimer Hwbuttons Hwx Hwy)
      as (after & Hcall & Hpointer' & Htimer' & Hx' & Hy' & Hbuttons' & Hframe).
    exists after. repeat split; try assumption.
    + intros chunk b offset Hbg Hbp Hbs. apply Hframe. exact Hbp.
    + intros Hfirst. apply Hframe. unfold playback_read_avoids. left. congruence.
  - destruct (Int.eq (playback_decrement timer) Int.zero) eqn:Hadvance.
    + destruct (generated_playback_advancing_record_call ge layout before
        controllers current pad stream record physical timer rawx rawy mask
        Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid
        Hphysical Htimer Hrawx Hrawy Hmask Hzero Hadvance Hwbuttons Hwx Hwy
        Hwtimer Hwcurrent)
        as (after & Hcall & Hpointer' & Htimer' & Hx' & Hy' & Hbuttons' & Hframe).
      exists after. repeat split; try assumption.
      intros Hfirst. exact (playback_byte_frame_preserves_header before after
        current pad stream record Hps ltac:(congruence) Hfirst Hframe).
    + destruct (generated_playback_positive_record_call ge layout before
        controllers current pad stream record physical timer rawx rawy mask
        Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid
        Hphysical Htimer Hrawx Hrawy Hmask Hzero Hadvance Hwbuttons Hwx Hwy
        Hwtimer)
        as (after & Hcall & Hpointer' & Htimer' & Hx' & Hy' & Hbuttons' & Hframe).
      exists after. repeat split; try assumption.
      * intros chunk b offset Hbg Hbp Hbs. apply Hframe; assumption.
      * intros Hfirst. apply Hframe.
        -- unfold playback_read_avoids. left. congruence.
        -- unfold playback_read_avoids. right. left. cbn. exact Hfirst.
Qed.

Definition demo_complete_playback_consumer_claim_us_jp : Prop :=
  demo_playback_all_timers_call_claim P.f_run_demo_inputs /\
  demo_playback_all_timers_call_claim jp_game_init.f_run_demo_inputs /\
  playback_buffer_bounds_claim.

Theorem generated_complete_playback_consumer_us_jp :
  demo_complete_playback_consumer_claim_us_jp.
Proof.
  split; [exact generated_playback_all_timers_call |].
  split; [exact generated_playback_all_timers_call |].
  exact playback_next_record_stays_in_buffer.
Qed.
