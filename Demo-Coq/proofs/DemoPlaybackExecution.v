From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

Lemma generated_playback_identical_us_jp :
  P.f_run_demo_inputs = jp_game_init.f_run_demo_inputs.
Proof. reflexivity. Qed.

Record playback_layout (ge : Clight.genv) : Type := {
  playback_controller_co : composite;
  playback_pad_co : composite;
  playback_record_co : composite;
  playback_controller_lookup : (genv_cenv ge) ! P._Controller = Some playback_controller_co;
  playback_pad_lookup : (genv_cenv ge) ! P.__319 = Some playback_pad_co;
  playback_record_lookup : (genv_cenv ge) ! P._DemoInput = Some playback_record_co;
  playback_controller_size : co_sizeof playback_controller_co = 28;
  playback_controller_data : field_offset (genv_cenv ge) P._controllerData
    (co_members playback_controller_co) = OK (24, Full);
  playback_pad_button : field_offset (genv_cenv ge) P._button
    (co_members playback_pad_co) = OK (0, Full);
  playback_pad_x : field_offset (genv_cenv ge) P._stick_x
    (co_members playback_pad_co) = OK (2, Full);
  playback_pad_y : field_offset (genv_cenv ge) P._stick_y
    (co_members playback_pad_co) = OK (3, Full);
  playback_record_timer : field_offset (genv_cenv ge) P._timer
    (co_members playback_record_co) = OK (0, Full);
  playback_record_x : field_offset (genv_cenv ge) P._rawStickX
    (co_members playback_record_co) = OK (1, Full);
  playback_record_y : field_offset (genv_cenv ge) P._rawStickY
    (co_members playback_record_co) = OK (2, Full);
  playback_record_buttons : field_offset (genv_cenv ge) P._buttonMask
    (co_members playback_record_co) = OK (3, Full);
  playback_record_size : co_sizeof playback_record_co = 4
}.

Definition playback_field_offset (record : ptrofs) (field : Z) : Z :=
  Ptrofs.unsigned (Ptrofs.add record (Ptrofs.repr field)).
Definition playback_masked_buttons (physical : int) : int :=
  Int.zero_ext 16 (Int.and physical (Int.repr 65343)).
Definition playback_start_button (physical : int) : int :=
  Int.zero_ext 16 (Int.and (playback_masked_buttons physical) (Int.repr 4096)).
Definition playback_record_buttons_value (mask : int) : int :=
  Int.zero_ext 16 (Int.add (Int.shl (Int.and mask (Int.repr 240)) (Int.repr 8))
    (Int.and mask (Int.repr 15))).
Definition playback_output_buttons (physical mask : int) : int :=
  Int.zero_ext 16 (Int.or (playback_record_buttons_value mask)
    (playback_start_button physical)).
Definition playback_decrement (timer : int) : int :=
  Int.zero_ext 8 (Int.sub timer Int.one).

Definition playback_read_avoids (chunk : memory_chunk) (b : block) (offset : Z)
    (written : block) (first past : Z) : Prop :=
  b <> written \/ offset + size_chunk chunk <= first \/ past <= offset.

Ltac playback_load :=
  first [eassumption |
    lazymatch goal with
    | |- Mem.load _ ?m _ _ = _ =>
      match goal with
      | H : Mem.store _ _ _ _ _ = Some m |- _ =>
        first
        [rewrite (Mem.load_store_same _ _ _ _ _ _ H); cbn -[Int.zero_ext Int.sign_ext Int.repr];
         repeat rewrite Int.zero_ext_idem by lia;
         repeat rewrite Int.sign_ext_idem by lia; reflexivity
        |rewrite (Mem.load_store_other _ _ _ _ _ _ H);
         [playback_load | first [left; congruence | right; left; cbn; lia | right; right; cbn; lia]]]
      end
    end].

Ltac playback_normalize :=
  first
  [match goal with
   | H : Int.eq ?x ?y = false |- _ = ?out =>
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

Ltac playback_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn [set_opttemp]; repeat rewrite PTree.gsspec; cbn;
      first [reflexivity | eassumption]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [playback_expr | playback_expr | playback_normalize]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [playback_expr | playback_normalize]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue;
      [playback_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; repeat rewrite Ptrofs.add_zero; playback_load]
             | eapply deref_loc_reference; reflexivity
             | eapply deref_loc_copy; reflexivity]]
  end
with playback_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; playback_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct;
      [playback_expr | reflexivity | eassumption | eassumption]
  end.

Ltac playback_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [playback_stmt | playback_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; playback_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [playback_lvalue | playback_expr | playback_normalize |
       eapply assign_loc_value; [reflexivity | cbn; repeat rewrite Ptrofs.add_zero; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
      [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
       [playback_expr | reflexivity | playback_stmt]
      |eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
       [playback_expr | reflexivity | playback_stmt]]
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  end.

(** Complete positive-record path with one logical controller and timer>1.
    Record identity and the untouched memory frame are conclusions.  The
    premises describe only the concrete cells read/written by generated code. *)
Theorem generated_playback_positive_record_body :
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
    Int.eq (playback_decrement timer) Int.zero = false ->
    Mem.valid_access before Mint16unsigned pad 0 Writable ->
    Mem.valid_access before Mint8signed pad 2 Writable ->
    Mem.valid_access before Mint8signed pad 3 Writable ->
    Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
    exists after le',
      exec_stmt function_entry2 ge empty_env le before
        (fn_body P.f_run_demo_inputs) E0 le' after Out_normal /\
      Mem.load Mptr after current 0 = Some (Vptr stream record) /\
      Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer)) /\
      Mem.load Mint8signed after pad 2 = Some (Vint rawx) /\
      Mem.load Mint8signed after pad 3 = Some (Vint rawy) /\
      Mem.load Mint16unsigned after pad 0 = Some (Vint (playback_output_buttons physical mask)) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset pad 0 4 ->
        playback_read_avoids chunk b offset stream (Ptrofs.unsigned record)
          (Ptrofs.unsigned record + 1) ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
  intros ge layout le before controllers current pad stream record physical timer rawx rawy mask
    Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
    Htimer Hrawx Hrawy Hmask Hpositive Hnotone Hwbuttons Hwx Hwy Hwtimer.
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
    (Vint (playback_decrement timer)) ltac:(demo_access)) as [after Hs6].
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
  assert (Hdecrement_read : Mem.load Mint8unsigned after stream
    (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer))).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs6).
    unfold playback_decrement. cbn [Val.load_result].
    rewrite Int.zero_ext_idem by lia. reflexivity. }
  exists after. eexists. split.
  - unfold playback_field_offset in Hrawx, Hrawy, Hmask.
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
    + intros chunk b offset Hbp Hbs.
      unfold playback_read_avoids in Hbp, Hbs.
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

Definition demo_playback_positive_record_call_claim (f : function) : Prop :=
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
    Int.eq (playback_decrement timer) Int.zero = false ->
    Mem.valid_access before Mint16unsigned pad 0 Writable ->
    Mem.valid_access before Mint8signed pad 2 Writable ->
    Mem.valid_access before Mint8signed pad 3 Writable ->
    Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef /\
      Mem.load Mptr after current 0 = Some (Vptr stream record) /\
      Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer)) /\
      Mem.load Mint8signed after pad 2 = Some (Vint rawx) /\
      Mem.load Mint8signed after pad 3 = Some (Vint rawy) /\
      Mem.load Mint16unsigned after pad 0 = Some (Vint (playback_output_buttons physical mask)) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset pad 0 4 ->
        playback_read_avoids chunk b offset stream (Ptrofs.unsigned record)
          (Ptrofs.unsigned record + 1) ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).

Theorem generated_playback_positive_record_call :
  demo_playback_positive_record_call_claim P.f_run_demo_inputs.
Proof.
  unfold demo_playback_positive_record_call_claim.
  intros ge layout before controllers current pad stream record physical timer rawx rawy mask
    Hcontrollers Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
    Htimer Hrawx Hrawy Hmask Hpositive Hnotone Hwbuttons Hwx Hwy Hwtimer.
  destruct (generated_playback_positive_record_body ge layout
    (create_undef_temps (fn_temps P.f_run_demo_inputs)) before controllers current
    pad stream record physical timer rawx rawy mask Hcontrollers Hcurrent Hpc Hpg
    Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical Htimer Hrawx Hrawy Hmask
    Hpositive Hnotone Hwbuttons Hwx Hwy Hwtimer)
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

Definition demo_playback_execution_claim_us_jp : Prop :=
  demo_playback_positive_record_call_claim P.f_run_demo_inputs /\
  demo_playback_positive_record_call_claim jp_game_init.f_run_demo_inputs.

Theorem generated_demo_playback_execution_us_jp :
  demo_playback_execution_claim_us_jp.
Proof. split; exact generated_playback_positive_record_call. Qed.
