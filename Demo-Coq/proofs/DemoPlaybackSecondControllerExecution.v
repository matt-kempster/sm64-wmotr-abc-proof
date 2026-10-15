From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop Ctypes
 Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution
 DemoPlaybackExecution DemoPlaybackAdvanceExecution DemoControllerCopyExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

Definition playback_second_decision (body : statement) : statement :=
 match body with
 | Ssequence _ (Ssequence _ (Sifthenelse _ (Ssequence decision _) _)) => decision
 | _ => Sskip
 end.
Definition playback_record_tail (body : statement) : statement :=
 match body with
 | Ssequence _ (Ssequence _ (Sifthenelse _ (Ssequence _ tail) _)) => tail
 | _ => Sskip
 end.
Definition playback_initial_normalization (body : statement) : statement :=
 match body with Ssequence normalize _ => normalize | _ => Sskip end.

Lemma generated_playback_normalization_executes :
 forall ge (layout : playback_layout ge) le before after controllers pads physical,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads Ptrofs.zero) ->
 Mem.load Mint16unsigned before pads 0 = Some (Vint physical) ->
 Mem.store Mint16unsigned before pads 0 (Vint (playback_masked_buttons physical)) = Some after ->
 exists le', exec_stmt function_entry2 ge empty_env le before
  (playback_initial_normalization (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal.
Proof.
 intros ge layout le before after controllers pads physical Hcontrollers Hpad Hphysical Hstore.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 unfold playback_masked_buttons in Hstore. eexists.
 unfold playback_initial_normalization. cbn [P.f_run_demo_inputs fn_body]. playback_stmt.
Qed.

Lemma generated_playback_second_selectors :
 playback_second_decision (fn_body P.f_run_demo_inputs) <> Sskip /\
 playback_record_tail (fn_body P.f_run_demo_inputs) <> Sskip /\
 playback_second_decision (fn_body P.f_run_demo_inputs) =
  playback_second_decision (fn_body jp_game_init.f_run_demo_inputs) /\
 playback_record_tail (fn_body P.f_run_demo_inputs) =
  playback_record_tail (fn_body jp_game_init.f_run_demo_inputs).
Proof. repeat split; first [discriminate | reflexivity]. Qed.

Theorem generated_playback_clears_second_pad :
 forall ge (layout : playback_layout ge) le before controllers pads,
 Genv.find_symbol ge P._gControllers = Some controllers -> pads <> controllers ->
 Mem.load Mptr before controllers 52 = Some (Vptr pads (Ptrofs.repr 6)) ->
 Mem.valid_access before Mint8signed pads 8 Writable ->
 Mem.valid_access before Mint8signed pads 9 Writable ->
 Mem.valid_access before Mint16unsigned pads 6 Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_second_decision (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mint8signed after pads 8 = Some Vzero /\
 Mem.load Mint8signed after pads 9 = Some Vzero /\
 Mem.load Mint16unsigned after pads 6 = Some Vzero /\
 Mem.unchanged_on (controller_outside_bytes pads 6 10) before after /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset pads 6 10 ->
  Mem.load chunk after b offset = Mem.load chunk before b offset) /\
 (forall chunk b offset permission,
  Mem.valid_access before chunk b offset permission ->
  Mem.valid_access after chunk b offset permission).
Proof.
 intros ge layout le before controllers pads Hcontrollers Hpc Hpad2 Hwx Hwy Hwb.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpad Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 assert (Hvalid2 : Mem.valid_pointer before pads (Ptrofs.unsigned (Ptrofs.repr 6)) = true).
 { change (Mem.valid_pointer before pads 6 = true). apply Mem.valid_pointer_nonempty_perm.
   eapply Mem.perm_implies; [exact (proj1 Hwb 6 ltac:(cbn; lia)) | constructor]. }
 destruct (Mem.valid_access_store before Mint8signed pads 8 Vzero Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint8signed pads 9 Vzero ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint16unsigned pads 6 Vzero ltac:(demo_access)) as [after Hs3].
 exists after. eexists. split.
 - unfold playback_second_decision. cbn [P.f_run_demo_inputs fn_body]. playback_stmt.
 - split; [playback_load |]. split; [playback_load |]. split; [playback_load |]. split.
   + eapply Mem.unchanged_on_trans with (m2 := m2).
     * eapply Mem.unchanged_on_trans with (m2 := m1);
        eapply controller_store_unchanged; eassumption || (cbn; lia).
     * eapply controller_store_unchanged; eassumption || (cbn; lia).
   + split.
     * intros chunk b offset Havoid.
       rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
        (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
         first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
       rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
        (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
         first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
       rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
        (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
         first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]). reflexivity.
     * intros. demo_access.
Qed.



Theorem generated_playback_tail_eof_executes :
 forall ge (layout : playback_layout ge) le before controllers current pads stream record,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads Ptrofs.zero) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some Vzero ->
 Mem.valid_access before Mint8signed pads 2 Writable ->
 Mem.valid_access before Mint8signed pads 3 Writable ->
 Mem.valid_access before Mint16unsigned pads 0 Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_record_tail (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mint8signed after pads 2 = Some Vzero /\
 Mem.load Mint8signed after pads 3 = Some Vzero /\
 Mem.load Mint16unsigned after pads 0 = Some (Vint (Int.repr 128)) /\
 (forall chunk b offset, playback_read_avoids chunk b offset pads 0 4 ->
   Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
 intros ge layout le before controllers current pads stream record
   Hcontrollers Hcurrent Hpc Hpg Hps Hpad Hpointer Htimer Hwx Hwy Hwb.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 destruct (Mem.valid_access_store before Mint8signed pads 2 Vzero Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint8signed pads 3 Vzero ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint16unsigned pads 0 (Vint (Int.repr 128)) ltac:(demo_access))
   as [after Hs3].
 exists after. eexists. split.
 - unfold playback_record_tail. cbn [P.f_run_demo_inputs fn_body]. playback_stmt.
 - split; [playback_load |]. split; [playback_load |]. split; [playback_load |].
   intros chunk b offset Havoid.
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
    (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
    (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
    (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]). reflexivity.
Qed.

Theorem generated_playback_tail_nonadvancing_executes :
 forall ge (layout : playback_layout ge) le before controllers current pads stream record
   physical timer rawx rawy mask,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 stream <> controllers -> stream <> current ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads Ptrofs.zero) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.load Mint16unsigned before pads 0 = Some (Vint (playback_masked_buttons physical)) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Int.eq timer Int.zero = false -> Int.eq (playback_decrement timer) Int.zero = false ->
 Mem.valid_access before Mint8signed pads 2 Writable ->
 Mem.valid_access before Mint8signed pads 3 Writable ->
 Mem.valid_access before Mint16unsigned pads 0 Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_record_tail (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mint8signed after pads 2 = Some (Vint rawx) /\
 Mem.load Mint8signed after pads 3 = Some (Vint rawy) /\
 Mem.load Mint16unsigned after pads 0 = Some (Vint (playback_output_buttons physical mask)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer)) /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset pads 0 4 ->
  playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
 intros ge layout le before controllers current pads stream record physical timer rawx rawy mask
  Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked Htimer Hrawx Hrawy Hmask
  Hpositive Hnotone Hwx Hwy Hwb Hwt.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 pose proof (Mem.load_cast _ _ _ _ _ Hrawx) as Hnormalx.
 pose proof (Mem.load_cast _ _ _ _ _ Hrawy) as Hnormaly.
 cbn in Hnormalx, Hnormaly.
 assert (Hcastx : Int.sign_ext 8 rawx = rawx) by congruence.
 assert (Hcasty : Int.sign_ext 8 rawy = rawy) by congruence.
 destruct (Mem.valid_access_store before Mint8signed pads 2 (Vint rawx) Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint8signed pads 3 (Vint rawy) ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint16unsigned pads 0 (Vint (playback_record_buttons_value mask))
   ltac:(demo_access)) as [m3 Hs3].
 destruct (Mem.valid_access_store m3 Mint16unsigned pads 0 (Vint (playback_output_buttons physical mask))
   ltac:(demo_access)) as [m4 Hs4].
 destruct (Mem.valid_access_store m4 Mint8unsigned stream (Ptrofs.unsigned record)
   (Vint (playback_decrement timer)) ltac:(demo_access)) as [after Hs5].
 assert (Hxread : Mem.load Mint8signed m1 pads 2 = Some (Vint rawx)).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1). cbn [Val.load_result]. rewrite Hcastx. reflexivity. }
 assert (Hyread : Mem.load Mint8signed m2 pads 3 = Some (Vint rawy)).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs2). cbn [Val.load_result]. rewrite Hcasty. reflexivity. }
 assert (Hdecoded : Mem.load Mint16unsigned m3 pads 0 = Some (Vint (playback_record_buttons_value mask))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs3). unfold playback_record_buttons_value.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Houtput : Mem.load Mint16unsigned m4 pads 0 = Some (Vint (playback_output_buttons physical mask))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs4). unfold playback_output_buttons.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Hdecrement : Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) =
   Some (Vint (playback_decrement timer))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs5). unfold playback_decrement.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 exists after. eexists. split.
 - unfold playback_field_offset in Hrawx, Hrawy, Hmask.
   unfold playback_masked_buttons, playback_record_buttons_value, playback_output_buttons,
    playback_start_button, playback_decrement in *.
   unfold playback_record_tail. cbn [P.f_run_demo_inputs fn_body]. playback_stmt.
 - split; [playback_load |]. split; [playback_load |].
   split; [playback_load |]. split; [exact Hdecrement |].
   intros chunk b offset Hpads Hstream.
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs5) by
    (unfold playback_read_avoids in Hstream; destruct Hstream as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]). reflexivity.
Qed.


Theorem generated_playback_tail_advancing_executes :
 forall ge (layout : playback_layout ge) le before controllers current pads stream record
   physical timer rawx rawy mask,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 stream <> controllers -> stream <> current ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads Ptrofs.zero) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.load Mint16unsigned before pads 0 = Some (Vint (playback_masked_buttons physical)) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Int.eq timer Int.zero = false -> Int.eq (playback_decrement timer) Int.zero = true ->
 Mem.valid_access before Mint8signed pads 2 Writable ->
 Mem.valid_access before Mint8signed pads 3 Writable ->
 Mem.valid_access before Mint16unsigned pads 0 Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 Mem.valid_access before Mptr current 0 Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_record_tail (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mint8signed after pads 2 = Some (Vint rawx) /\
 Mem.load Mint8signed after pads 3 = Some (Vint rawy) /\
 Mem.load Mint16unsigned after pads 0 = Some (Vint (playback_output_buttons physical mask)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer)) /\
 Mem.load Mptr after current 0 = Some (Vptr stream (playback_advance record)) /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset current 0 4 ->
  playback_read_avoids chunk b offset pads 0 4 ->
  playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
 intros ge layout le before controllers current pads stream record physical timer rawx rawy mask
  Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked Htimer Hrawx Hrawy Hmask
  Hpositive Hlast Hwx Hwy Hwb Hwt Hwc.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 pose proof (Mem.load_cast _ _ _ _ _ Hrawx) as Hnormalx.
 pose proof (Mem.load_cast _ _ _ _ _ Hrawy) as Hnormaly.
 cbn in Hnormalx, Hnormaly.
 assert (Hcastx : Int.sign_ext 8 rawx = rawx) by congruence.
 assert (Hcasty : Int.sign_ext 8 rawy = rawy) by congruence.
 destruct (Mem.valid_access_store before Mint8signed pads 2 (Vint rawx) Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint8signed pads 3 (Vint rawy) ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint16unsigned pads 0 (Vint (playback_record_buttons_value mask))
   ltac:(demo_access)) as [m3 Hs3].
 destruct (Mem.valid_access_store m3 Mint16unsigned pads 0 (Vint (playback_output_buttons physical mask))
   ltac:(demo_access)) as [m4 Hs4].
 destruct (Mem.valid_access_store m4 Mint8unsigned stream (Ptrofs.unsigned record)
   (Vint (playback_decrement timer)) ltac:(demo_access)) as [m5 Hs5].
 destruct (Mem.valid_access_store m5 Mptr current 0 (Vptr stream (playback_advance record))
   ltac:(demo_access)) as [after Hs6].
 assert (Hxread : Mem.load Mint8signed m1 pads 2 = Some (Vint rawx)).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1). cbn [Val.load_result]. rewrite Hcastx. reflexivity. }
 assert (Hyread : Mem.load Mint8signed m2 pads 3 = Some (Vint rawy)).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs2). cbn [Val.load_result]. rewrite Hcasty. reflexivity. }
 assert (Hdecoded : Mem.load Mint16unsigned m3 pads 0 = Some (Vint (playback_record_buttons_value mask))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs3). unfold playback_record_buttons_value.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Houtput : Mem.load Mint16unsigned m4 pads 0 = Some (Vint (playback_output_buttons physical mask))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs4). unfold playback_output_buttons.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Hdecrement : Mem.load Mint8unsigned m5 stream (Ptrofs.unsigned record) =
   Some (Vint (playback_decrement timer))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs5). unfold playback_decrement.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 exists after. eexists. split.
 - unfold playback_advance in Hs6.
   unfold playback_field_offset in Hrawx, Hrawy, Hmask.
   unfold playback_masked_buttons, playback_record_buttons_value, playback_output_buttons,
    playback_start_button, playback_decrement in *.
   unfold playback_record_tail. cbn [P.f_run_demo_inputs fn_body]. playback_stmt.
 - split; [playback_load |]. split; [playback_load |].
   split; [playback_load |]. split; [playback_load |]. split; [playback_load |].
   intros chunk b offset Hcurrentrange Hpads Hstream.
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs6) by exact Hcurrentrange.
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs5) by
    (unfold playback_read_avoids in Hstream; destruct Hstream as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]). reflexivity.
Qed.


Theorem generated_playback_tail_all_timers_executes :
 forall ge (layout : playback_layout ge) le before controllers current pads stream record
   physical timer rawx rawy mask,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 stream <> controllers -> stream <> current ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads Ptrofs.zero) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.load Mint16unsigned before pads 0 = Some (Vint (playback_masked_buttons physical)) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Mem.valid_access before Mint8signed pads 2 Writable ->
 Mem.valid_access before Mint8signed pads 3 Writable ->
 Mem.valid_access before Mint16unsigned pads 0 Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 Mem.valid_access before Mptr current 0 Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_record_tail (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mptr after current 0 = Some (Vptr stream (playback_next_record timer record)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_next_timer timer)) /\
 Mem.load Mint8signed after pads 2 = Some (Vint (playback_next_stick timer rawx)) /\
 Mem.load Mint8signed after pads 3 = Some (Vint (playback_next_stick timer rawy)) /\
 Mem.load Mint16unsigned after pads 0 = Some (Vint (playback_next_buttons timer physical mask)) /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset current 0 4 ->
  playback_read_avoids chunk b offset pads 0 4 ->
  playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
 intros ge layout le before controllers current pads stream record physical timer rawx rawy mask
  Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked Htimer Hrawx Hrawy Hmask
  Hwx Hwy Hwb Hwt Hwc.
 unfold playback_next_record, playback_next_timer, playback_next_stick, playback_next_buttons.
 destruct (Int.eq timer Int.zero) eqn:Hzero.
 - pose proof (Int.eq_spec timer Int.zero) as Heq. rewrite Hzero in Heq. subst timer.
   destruct (generated_playback_tail_eof_executes ge layout le before controllers current pads stream record
     Hcontrollers Hcurrent Hpc Hpg Hps Hpad Hpointer Htimer Hwx Hwy Hwb)
     as (after & le' & Hexec & Hx & Hy & Hb & Hframe).
   exists after, le'. split; [exact Hexec |].
   split; [rewrite Hframe by (unfold playback_read_avoids; left; apply not_eq_sym; exact Hpg); exact Hpointer |].
   split; [rewrite Hframe by (unfold playback_read_avoids; left; apply not_eq_sym; exact Hps); exact Htimer |].
   split; [exact Hx |]. split; [exact Hy |]. split; [exact Hb |]. intros. apply Hframe. assumption.
 - destruct (Int.eq (playback_decrement timer) Int.zero) eqn:Hlast.
   + destruct (generated_playback_tail_advancing_executes ge layout le before controllers current pads stream record
       physical timer rawx rawy mask Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked
       Htimer Hrawx Hrawy Hmask Hzero Hlast Hwx Hwy Hwb Hwt Hwc)
       as (after & le' & Hexec & Hx & Hy & Hb & Ht & Hp & Hframe).
     exists after, le'. repeat split; assumption.
   + destruct (generated_playback_tail_nonadvancing_executes ge layout le before controllers current pads stream record
       physical timer rawx rawy mask Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked
       Htimer Hrawx Hrawy Hmask Hzero Hlast Hwx Hwy Hwb Hwt)
       as (after & le' & Hexec & Hx & Hy & Hb & Ht & Hframe).
     exists after, le'. split; [exact Hexec |]. split.
     * rewrite Hframe by (unfold playback_read_avoids; left; apply not_eq_sym; assumption). exact Hpointer.
     * split; [exact Ht |]. split; [exact Hx |]. split; [exact Hy |]. split; [exact Hb |].
       intros. apply Hframe; assumption.
Qed.

Definition demo_connected_second_playback_claim (f : function) : Prop :=
 forall ge (layout : playback_layout ge) before controllers current pads stream record
   physical timer rawx rawy mask,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 stream <> controllers -> stream <> current ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads Ptrofs.zero) ->
 Mem.load Mptr before controllers 52 = Some (Vptr pads (Ptrofs.repr 6)) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.valid_pointer before stream (Ptrofs.unsigned record) = true ->
 Mem.load Mint16unsigned before pads 0 = Some (Vint physical) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Mem.valid_access before Mint16unsigned pads 0 Writable ->
 Mem.valid_access before Mint8signed pads 2 Writable ->
 Mem.valid_access before Mint8signed pads 3 Writable ->
 Mem.valid_access before Mint8signed pads 8 Writable ->
 Mem.valid_access before Mint8signed pads 9 Writable ->
 Mem.valid_access before Mint16unsigned pads 6 Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 Mem.valid_access before Mptr current 0 Writable ->
 exists after,
 eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef /\
 Mem.load Mptr after current 0 = Some (Vptr stream (playback_next_record timer record)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_next_timer timer)) /\
 Mem.load Mint8signed after pads 2 = Some (Vint (playback_next_stick timer rawx)) /\
 Mem.load Mint8signed after pads 3 = Some (Vint (playback_next_stick timer rawy)) /\
 Mem.load Mint16unsigned after pads 0 = Some (Vint (playback_next_buttons timer physical mask)) /\
 Mem.load Mint8signed after pads 8 = Some Vzero /\
 Mem.load Mint8signed after pads 9 = Some Vzero /\
 Mem.load Mint16unsigned after pads 6 = Some Vzero /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset current 0 4 ->
  playback_read_avoids chunk b offset pads 0 4 ->
  playback_read_avoids chunk b offset pads 6 10 ->
  playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset) /\
 (4 <= Ptrofs.unsigned record -> Mem.load Mint32 after stream 0 = Mem.load Mint32 before stream 0).

Theorem generated_connected_second_playback_call :
 demo_connected_second_playback_claim P.f_run_demo_inputs.
Proof.
 intros ge layout before controllers current pads stream record physical timer rawx rawy mask
   Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
   Htimer Hrawx Hrawy Hmask Hwb Hwx Hwy Hw2x Hw2y Hw2b Hwt Hwc.
 destruct (Mem.valid_access_store before Mint16unsigned pads 0
   (Vint (playback_masked_buttons physical)) Hwb) as [masked Hstore].
 destruct (generated_playback_normalization_executes ge layout
   (create_undef_temps (fn_temps P.f_run_demo_inputs)) before masked controllers pads physical
   Hcontrollers Hpad Hphysical Hstore) as [lenorm Hnorm].
 assert (Hmasked : Mem.load Mint16unsigned masked pads 0 = Some (Vint (playback_masked_buttons physical))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore). unfold playback_masked_buttons.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Hvalid' : Mem.valid_pointer masked stream (Ptrofs.unsigned record) = true).
 { apply Mem.valid_pointer_nonempty_perm. eapply Mem.perm_store_1; [exact Hstore |].
   apply Mem.valid_pointer_nonempty_perm. exact Hvalid. }
 set (lecurrent := PTree.set P._t'2 (Vptr stream record) lenorm).
 destruct (generated_playback_clears_second_pad ge layout lecurrent masked controllers pads
   Hcontrollers Hpc ltac:(playback_load)
   ltac:(demo_access) ltac:(demo_access) ltac:(demo_access))
   as (cleared & lecleared & Hclear & Hclearx & Hcleary & Hclearb & Hclearunchanged & Hclearframe & Hclearaccess).
 assert (Hprepared : forall chunk b offset,
   playback_read_avoids chunk b offset pads 0 2 ->
   playback_read_avoids chunk b offset pads 6 10 ->
   Mem.load chunk cleared b offset = Mem.load chunk before b offset).
 { abstract (intros chunk b offset Hfirst Hsecond; rewrite Hclearframe by exact Hsecond;
     apply (Mem.load_store_other _ _ _ _ _ _ Hstore); exact Hfirst). }
 assert (Hprepared_other : forall chunk b offset, b <> pads ->
   Mem.load chunk cleared b offset = Mem.load chunk before b offset).
 { abstract (intros; apply Hprepared; unfold playback_read_avoids; left; assumption). }
 assert (Hmasked' : Mem.load Mint16unsigned cleared pads 0 = Some (Vint (playback_masked_buttons physical))).
 { rewrite Hclearframe by (unfold playback_read_avoids; right; left; vm_compute; discriminate). exact Hmasked. }
 destruct (generated_playback_tail_all_timers_executes ge layout lecleared cleared controllers current pads stream record
   physical timer rawx rawy mask Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hpc); exact Hpad)
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hpg); exact Hpointer)
   Hmasked'
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hps); exact Htimer)
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hps); exact Hrawx)
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hps); exact Hrawy)
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hps); exact Hmask)
   ltac:(apply Hclearaccess; demo_access) ltac:(apply Hclearaccess; demo_access)
   ltac:(apply Hclearaccess; demo_access) ltac:(apply Hclearaccess; demo_access)
   ltac:(apply Hclearaccess; demo_access))
   as (after & le' & Htail & Hpointer' & Htimer' & Hx & Hy & Hb & Htailframe).
 assert (Hbody : exec_stmt function_entry2 ge empty_env
   (create_undef_temps (fn_temps P.f_run_demo_inputs)) before (fn_body P.f_run_demo_inputs)
   E0 le' after Out_normal).
 { destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
     Hcontrollersize Hdata Hbutton Hpadx Hpady Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
   unfold playback_initial_normalization in Hnorm.
   unfold playback_second_decision in Hclear. unfold playback_record_tail in Htail.
   cbn [P.f_run_demo_inputs fn_body] in Hnorm, Hclear, Htail |- *.
   eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hnorm |].
   eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
   - apply exec_Sset. playback_expr.
   - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
     + unfold lecurrent in Hclear. playback_expr.
     + reflexivity.
     + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hclear | exact Htail]. }
 assert (Hframe : forall chunk b offset,
   playback_read_avoids chunk b offset current 0 4 ->
   playback_read_avoids chunk b offset pads 0 4 ->
   playback_read_avoids chunk b offset pads 6 10 ->
   playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
   Mem.load chunk after b offset = Mem.load chunk before b offset).
 { abstract (intros chunk b offset Hc Hp Hp2 Hs; rewrite Htailframe by assumption;
     apply Hprepared; [unfold playback_read_avoids in Hp |- *; intuition lia | exact Hp2]). }
 exists after. split.
 - eapply eval_funcall_internal with (e := empty_env)
     (le1 := create_undef_temps (fn_temps P.f_run_demo_inputs))
     (le2 := le') (m1 := before) (m2 := after) (out := Out_normal).
   + constructor; try constructor; unfold list_disjoint; cbn; tauto.
   + exact Hbody.
   + reflexivity.
   + reflexivity.
 - split; [exact Hpointer' |]. split; [exact Htimer' |]. split; [exact Hx |]. split; [exact Hy |].
   split; [exact Hb |].
   do 3 (split; [rewrite Htailframe by (unfold playback_read_avoids;
      first [left; apply not_eq_sym; exact Hpg | right; right; cbn; lia | left; exact Hps]); assumption |]).
   split; [exact Hframe |]. intros Hfirst. apply Hframe; unfold playback_read_avoids;
    first [left; exact Hsg | left; apply not_eq_sym; exact Hps | right; left; cbn; exact Hfirst].
Qed.

Definition demo_connected_second_playback_claim_us_jp : Prop :=
 demo_connected_second_playback_claim P.f_run_demo_inputs /\
 demo_connected_second_playback_claim jp_game_init.f_run_demo_inputs.

Theorem generated_connected_second_playback_us_jp : demo_connected_second_playback_claim_us_jp.
Proof. split; exact generated_connected_second_playback_call. Qed.
