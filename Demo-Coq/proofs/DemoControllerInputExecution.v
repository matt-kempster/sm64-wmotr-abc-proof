From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Floats Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution
  DemoPlaybackExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

Record controller_input_layout (ge : Clight.genv) : Type := {
  input_playback_layout : playback_layout ge;
  input_raw_x : field_offset (genv_cenv ge) P._rawStickX
    (co_members (playback_controller_co ge input_playback_layout)) = OK (0, Full);
  input_raw_y : field_offset (genv_cenv ge) P._rawStickY
    (co_members (playback_controller_co ge input_playback_layout)) = OK (2, Full);
  input_stick_x : field_offset (genv_cenv ge) P._stickX
    (co_members (playback_controller_co ge input_playback_layout)) = OK (4, Full);
  input_stick_y : field_offset (genv_cenv ge) P._stickY
    (co_members (playback_controller_co ge input_playback_layout)) = OK (8, Full);
  input_stick_mag : field_offset (genv_cenv ge) P._stickMag
    (co_members (playback_controller_co ge input_playback_layout)) = OK (12, Full);
  input_button_down : field_offset (genv_cenv ge) P._buttonDown
    (co_members (playback_controller_co ge input_playback_layout)) = OK (16, Full);
  input_button_pressed : field_offset (genv_cenv ge) P._buttonPressed
    (co_members (playback_controller_co ge input_playback_layout)) = OK (18, Full)
}.

Definition generated_connected_controller_branch (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _
      (Ssequence (Ssequence _
        (Sloop (Ssequence _ (Ssequence _ (Ssequence _
          (Sifthenelse _ connected _)))) _)) _)) => connected
  | _ => Sskip
  end.

Definition controller_copy_stages (body : statement)
    : statement * statement * statement * statement * statement :=
  match generated_connected_controller_branch body with
  | Ssequence x (Ssequence y (Ssequence pressed (Ssequence down analog))) =>
      (x, y, pressed, down, analog)
  | _ => (Sskip, Sskip, Sskip, Sskip, Sskip)
  end.

Definition controller_copy_prefix (body : statement) : statement :=
  let '(x, y, pressed, down, _) := controller_copy_stages body in
  Ssequence x (Ssequence y (Ssequence pressed down)).

Lemma generated_controller_copy_stages_decompose :
  let '(x, y, pressed, down, analog) :=
    controller_copy_stages (fn_body P.f_read_controller_inputs) in
  generated_connected_controller_branch (fn_body P.f_read_controller_inputs) =
    Ssequence x (Ssequence y (Ssequence pressed (Ssequence down analog))).
Proof. reflexivity. Qed.

Lemma generated_controller_processing_identical_us_jp :
  P.f_read_controller_inputs = jp_game_init.f_read_controller_inputs /\
  P.f_adjust_analog_stick = jp_game_init.f_adjust_analog_stick.
Proof. split; reflexivity. Qed.

Definition controller_pressed_value (buttons previous : int) : int :=
  Int.zero_ext 16 (Int.and buttons (Int.xor buttons previous)).

Theorem generated_controller_copy_prefix_executes :
  forall ge (layout : controller_input_layout ge) le before
      controller pad rawx rawy buttons previous,
    le ! P._controller = Some (Vptr controller Ptrofs.zero) ->
    controller <> pad ->
    Mem.load Mptr before controller 24 = Some (Vptr pad Ptrofs.zero) ->
    Mem.load Mint8signed before pad 2 = Some (Vint rawx) ->
    Mem.load Mint8signed before pad 3 = Some (Vint rawy) ->
    Mem.load Mint16unsigned before pad 0 = Some (Vint buttons) ->
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
  intros ge layout le before controller pad rawx rawy buttons previous Hcontroller
    Hseparate Hpad Hrawx Hrawy Hbuttons Hprevious Hwx Hwy Hwpressed Hwdown.
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
  assert (Hpad1 : Mem.load Mptr m1 controller 24 = Some (Vptr pad Ptrofs.zero)) by playback_load.
  assert (Hpad2 : Mem.load Mptr m2 controller 24 = Some (Vptr pad Ptrofs.zero)) by playback_load.
  assert (Hpad3 : Mem.load Mptr m3 controller 24 = Some (Vptr pad Ptrofs.zero)) by playback_load.
  assert (Hprevious2 : Mem.load Mint16unsigned m2 controller 16 = Some (Vint previous)) by playback_load.
  assert (Hbuttons2 : Mem.load Mint16unsigned m2 pad 0 = Some (Vint buttons)) by playback_load.
  assert (Hbuttons3 : Mem.load Mint16unsigned m3 pad 0 = Some (Vint buttons)) by playback_load.
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
      * eapply exec_Sset. playback_expr.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset. playback_expr.
        -- playback_stmt.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset. playback_expr.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset. playback_expr.
           ++ playback_stmt.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- playback_stmt.
        -- playback_stmt.
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

Definition controller_float_zero : float32 := Float32.of_int Int.zero.
Definition controller_zero_magnitude_argument : float32 :=
  Float32.add (Float32.mul controller_float_zero controller_float_zero)
    (Float32.mul controller_float_zero controller_float_zero).
Definition controller_sqrt_external : external_function :=
  EF_external "sqrtf" (mksignature [AST.Xsingle] AST.Xsingle cc_default).
Definition controller_sqrt_fundef : Clight.fundef :=
  External controller_sqrt_external [tfloat] tfloat cc_default.

Ltac analog_normalize :=
  first
  [match goal with
   | H : Float32.cmp ?comparison ?x ?y = ?flag |- _ = ?out =>
       change (Some (Val.of_bool (Float32.cmp comparison x y)) = out);
       rewrite H; reflexivity
   end
  |cbn -[Int.sign_ext Int.zero_ext Int.repr Ptrofs.repr Ptrofs.add Ptrofs.mul
     Ptrofs.of_ints Float32.of_int Float32.mul Float32.add Float32.cmp];
   repeat match goal with
   | H : (genv_cenv ?ge) ! ?id = Some ?co |-
       context [match (genv_cenv ?ge) ! ?id with _ => _ end] => rewrite H
   | H : co_sizeof ?co = _ |- context [co_sizeof ?co] => rewrite H
   end;
   cbn -[Int.sign_ext Int.zero_ext Int.repr Float32.of_int Float32.mul Float32.add Float32.cmp];
   repeat match goal with
   | H : Int.sign_ext ?bits ?value = ?value |- context [Int.sign_ext ?bits ?value] => rewrite H
   | H : Int.zero_ext ?bits ?value = ?value |- context [Int.zero_ext ?bits ?value] => rewrite H
   end;
   repeat rewrite Int.zero_ext_idem by lia;
   repeat rewrite Int.sign_ext_idem by lia;
   repeat rewrite Ptrofs.add_zero; reflexivity].

Ltac analog_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn [set_opttemp]; repeat rewrite PTree.gsspec; cbn;
      first [reflexivity | eassumption]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [analog_expr | analog_normalize]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [analog_expr | analog_expr | analog_normalize]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [analog_expr | analog_normalize]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue;
      [analog_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; repeat rewrite Ptrofs.add_zero; playback_load]
             | eapply deref_loc_reference; reflexivity
             | eapply deref_loc_copy; reflexivity]]
  end
with analog_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [first [reflexivity | eassumption] | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; analog_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct;
      [analog_expr | reflexivity | eassumption | eassumption]
  end.

Ltac analog_arguments :=
  first [apply eval_Enil |
    eapply eval_Econs; [analog_expr | analog_normalize | analog_arguments]].

Ltac analog_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [analog_stmt | analog_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; analog_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [analog_lvalue | analog_expr | analog_normalize |
       eapply assign_loc_value; [reflexivity | cbn; repeat rewrite Ptrofs.add_zero; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
      [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
       [analog_expr | reflexivity | analog_stmt]
      |eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
       [analog_expr | reflexivity | analog_stmt]]
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | analog_expr | analog_arguments |
       cbn; eassumption | reflexivity |
       eapply eval_funcall_external; eassumption]
  end.

(** Actual analog processing for a neutral input, with the real named math
    external's pure result contract.  No controller execution is assumed. *)
Theorem generated_neutral_analog_body_executes :
  forall ge (layout : controller_input_layout ge) e le before controller sqrt magnitude,
    e ! P._sqrtf = None ->
    le ! P._controller = Some (Vptr controller Ptrofs.zero) ->
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle controller_zero_magnitude_argument] m E0 (Vsingle magnitude) m) ->
    Float32.cmp Cgt magnitude (Float32.of_int (Int.repr 64)) = false ->
    Mem.load Mint16signed before controller 0 = Some Vzero ->
    Mem.load Mint16signed before controller 2 = Some Vzero ->
    Mem.valid_access before Mfloat32 controller 4 Writable ->
    Mem.valid_access before Mfloat32 controller 8 Writable ->
    Mem.valid_access before Mfloat32 controller 12 Writable ->
    exists after le',
      exec_stmt function_entry2 ge e le before
        (fn_body P.f_adjust_analog_stick) E0 le' after Out_normal /\
      Mem.load Mfloat32 after controller 4 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 8 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 12 = Some (Vsingle magnitude) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset controller 4 16 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      (forall b offset kind perm,
        Mem.perm before b offset kind perm -> Mem.perm after b offset kind perm).
Proof.
  intros ge layout e le before controller sqrt magnitude Hlocal Hcontroller Hsqrt Hfind
    Hmath Hbounded Hrawx Hrawy Hwx Hwy Hwm.
  destruct layout as [layout Hraw_x Hraw_y Hstick_x Hstick_y Hstick_mag Hdown Hpressed].
  destruct layout as [controller_co pad_co record_co Hcontroller_co Hpad_co Hrecord_co
    Hcontroller_size Hdata Hbutton Hx Hy Htimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  cbn in Hraw_x, Hraw_y, Hstick_x, Hstick_y, Hstick_mag, Hdown, Hpressed.
  destruct (Mem.valid_access_store before Mfloat32 controller 4
    (Vsingle controller_float_zero) Hwx) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mfloat32 controller 8
    (Vsingle controller_float_zero) ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mfloat32 controller 12
    (Vsingle magnitude) ltac:(demo_access)) as [after Hs3].
  assert (Hrawx2 : Mem.load Mint16signed m2 controller 0 = Some Vzero) by playback_load.
  assert (Hrawy2 : Mem.load Mint16signed m2 controller 2 = Some Vzero) by playback_load.
  assert (Hx2 : Mem.load Mfloat32 m2 controller 4 = Some (Vsingle controller_float_zero)) by playback_load.
  assert (Hy2 : Mem.load Mfloat32 m2 controller 8 = Some (Vsingle controller_float_zero)) by playback_load.
  assert (Hmag3 : Mem.load Mfloat32 after controller 12 = Some (Vsingle magnitude)) by playback_load.
  pose proof (Hmath m2) as Hsqrtcall.
  exists after. eexists. split.
  - unfold controller_float_zero, controller_zero_magnitude_argument,
      controller_sqrt_fundef, controller_sqrt_external in *.
    cbn [P.f_adjust_analog_stick fn_body]. analog_stmt.
  - repeat split; try playback_load.
    + intros chunk b offset Hrange. unfold playback_read_avoids in Hrange.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
      (destruct Hrange as [H | [H | H]];
        first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
      (destruct Hrange as [H | [H | H]];
        first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
      (destruct Hrange as [H | [H | H]];
        first [left; congruence | right; right; cbn; lia | right; left; cbn; lia]).
    reflexivity.
    + intros b offset kind perm Hperm.
    eapply Mem.perm_store_1; [exact Hs3 |].
    eapply Mem.perm_store_1; [exact Hs2 |].
    eapply Mem.perm_store_1; eassumption.
Qed.

Definition controller_analog_env (filler : block) : env :=
  PTree.set P._filler (filler, tarray tuchar 8) empty_env.
Definition controller_analog_temps (controller : block) : temp_env :=
  PTree.set P._controller (Vptr controller Ptrofs.zero)
    (create_undef_temps (fn_temps P.f_adjust_analog_stick)).

Theorem generated_neutral_analog_call_executes :
  forall ge (layout : controller_input_layout ge) before controller sqrt magnitude,
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle controller_zero_magnitude_argument] m E0 (Vsingle magnitude) m) ->
    Float32.cmp Cgt magnitude (Float32.of_int (Int.repr 64)) = false ->
    Mem.load Mint16signed before controller 0 = Some Vzero ->
    Mem.load Mint16signed before controller 2 = Some Vzero ->
    Mem.valid_access before Mfloat32 controller 4 Writable ->
    Mem.valid_access before Mfloat32 controller 8 Writable ->
    Mem.valid_access before Mfloat32 controller 12 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal P.f_adjust_analog_stick)
        [Vptr controller Ptrofs.zero] E0 after Vundef /\
      Mem.load Mfloat32 after controller 4 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 8 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 12 = Some (Vsingle magnitude) /\
      (forall chunk b offset,
        Mem.valid_block before b ->
        playback_read_avoids chunk b offset controller 4 16 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
  intros ge layout before controller sqrt magnitude Hsqrt Hfind Hmath Hbounded
    Hrawx Hrawy Hwx Hwy Hwm.
  destruct (Mem.alloc before 0 8) as [allocated filler] eqn:Ha.
  assert (Hvalidcontroller : Mem.valid_block before controller).
  { eapply Mem.valid_access_valid_block. eapply Mem.valid_access_implies.
    - eapply Mem.load_valid_access. exact Hrawx.
    - constructor. }
  assert (Hdistinct : controller <> filler).
  { intros ->. exact (Mem.fresh_block_alloc _ _ _ _ _ Ha Hvalidcontroller). }
  assert (Hentry : function_entry2 ge P.f_adjust_analog_stick
      [Vptr controller Ptrofs.zero] before (controller_analog_env filler)
      (controller_analog_temps controller) allocated).
  { apply function_entry2_intro.
    - constructor; [cbn; tauto | constructor].
    - constructor; [cbn; tauto | constructor].
    - vm_compute. intuition congruence.
    - eapply alloc_variables_cons with (m1 := allocated) (b1 := filler).
      + change (Mem.alloc before 0 8 = (allocated, filler)). exact Ha.
      + constructor.
    - reflexivity. }
  destruct (generated_neutral_analog_body_executes ge layout
    (controller_analog_env filler) (controller_analog_temps controller) allocated
    controller sqrt magnitude ltac:(reflexivity)
    ltac:(unfold controller_analog_temps; rewrite PTree.gss; reflexivity)
    Hsqrt Hfind Hmath Hbounded
    ltac:(eapply Mem.load_alloc_other; eassumption)
    ltac:(eapply Mem.load_alloc_other; eassumption)
    ltac:(eapply Mem.valid_access_alloc_other; eassumption)
    ltac:(eapply Mem.valid_access_alloc_other; eassumption)
    ltac:(eapply Mem.valid_access_alloc_other; eassumption))
    as (called & le' & Hbody & Hx & Hy & Hmag & Hframe & Hperm).
  destruct (Mem.range_perm_free called filler 0 8
    ltac:(intros offset Hrange; apply Hperm;
      eapply Mem.perm_alloc_2; eassumption)) as [after Hfree].
  exists after. split.
  - eapply eval_funcall_internal with (e := controller_analog_env filler)
      (le1 := controller_analog_temps controller) (le2 := le')
      (m1 := allocated) (m2 := called) (out := Out_normal).
    + exact Hentry.
    + exact Hbody.
    + reflexivity.
    + change (Mem.free_list called [(filler, 0, 8)] = Some after).
      cbn. rewrite Hfree. reflexivity.
  - repeat split.
    + rewrite (Mem.load_free _ _ _ _ _ Hfree) by (left; exact Hdistinct). exact Hx.
    + rewrite (Mem.load_free _ _ _ _ _ Hfree) by (left; exact Hdistinct). exact Hy.
    + rewrite (Mem.load_free _ _ _ _ _ Hfree) by (left; exact Hdistinct). exact Hmag.
    + intros chunk b offset Hvalid Havoid.
      assert (Hbf : b <> filler).
      { intros ->. exact (Mem.fresh_block_alloc _ _ _ _ _ Ha Hvalid). }
      rewrite (Mem.load_free _ _ _ _ _ Hfree) by (left; exact Hbf).
      rewrite Hframe by exact Havoid.
      exact (Mem.load_alloc_unchanged _ _ _ _ _ Ha chunk b offset Hvalid).
Qed.

Lemma controller_normal_sequence_inv :
  forall ge e le before a b le' after,
    exec_stmt function_entry2 ge e le before (Ssequence a b) E0 le' after Out_normal ->
    exists middle lem,
      exec_stmt function_entry2 ge e le before a E0 lem middle Out_normal /\
      exec_stmt function_entry2 ge e lem middle b E0 le' after Out_normal.
Proof.
  intros ge e le before a b le' after Hexec.
  inversion Hexec; subst; try contradiction.
  match goal with H : Eapp _ _ = E0 |- _ =>
    apply Eapp_E0_inv in H; destruct H; subst end.
  eexists. eexists. split; eassumption.
Qed.

Lemma controller_prefix_then_analog :
  forall ge le before middle lem after le',
    exec_stmt function_entry2 ge empty_env le before
      (controller_copy_prefix (fn_body P.f_read_controller_inputs)) E0 lem middle Out_normal ->
    exec_stmt function_entry2 ge empty_env lem middle
      (let '(_, _, _, _, analog) :=
        controller_copy_stages (fn_body P.f_read_controller_inputs) in analog)
      E0 le' after Out_normal ->
    exec_stmt function_entry2 ge empty_env le before
      (generated_connected_controller_branch (fn_body P.f_read_controller_inputs))
      E0 le' after Out_normal.
Proof.
  intros ge le before middle lem after le' Hprefix Hanalog.
  unfold controller_copy_prefix, controller_copy_stages,
    generated_connected_controller_branch in *.
  cbn [P.f_read_controller_inputs fn_body] in *.
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Hprefix)
    as (m1 & le1 & Hx & Htail1).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Htail1)
    as (m2 & le2 & Hy & Htail2).
  destruct (controller_normal_sequence_inv _ _ _ _ _ _ _ _ Htail2)
    as (m3 & le3 & Hpressed & Hdown).
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hx |].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hy |].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hpressed |].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); eassumption.
Qed.

Definition controller_connected_neutral_claim (body : statement) : Prop :=
  forall ge (layout : controller_input_layout ge) le before
      controller pad analog sqrt buttons previous magnitude,
    le ! P._controller = Some (Vptr controller Ptrofs.zero) ->
    controller <> pad ->
    Genv.find_symbol ge P._adjust_analog_stick = Some analog ->
    Genv.find_funct ge (Vptr analog Ptrofs.zero) = Some (Internal P.f_adjust_analog_stick) ->
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle controller_zero_magnitude_argument] m E0 (Vsingle magnitude) m) ->
    Float32.cmp Cgt magnitude (Float32.of_int (Int.repr 64)) = false ->
    Mem.load Mptr before controller 24 = Some (Vptr pad Ptrofs.zero) ->
    Mem.load Mint8signed before pad 2 = Some Vzero ->
    Mem.load Mint8signed before pad 3 = Some Vzero ->
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
        (generated_connected_controller_branch body) E0 le' after Out_normal /\
      Mem.load Mint16signed after controller 0 = Some Vzero /\
      Mem.load Mint16signed after controller 2 = Some Vzero /\
      Mem.load Mint16unsigned after controller 18 =
        Some (Vint (controller_pressed_value buttons previous)) /\
      Mem.load Mint16unsigned after controller 16 = Some (Vint buttons) /\
      Mem.load Mfloat32 after controller 4 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 8 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 12 = Some (Vsingle magnitude) /\
      (forall chunk b offset,
        Mem.valid_block before b ->
        playback_read_avoids chunk b offset controller 0 20 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset).

Theorem generated_connected_neutral_controller_executes :
  controller_connected_neutral_claim (fn_body P.f_read_controller_inputs).
Proof.
  unfold controller_connected_neutral_claim.
  intros ge layout le before controller pad analog sqrt buttons previous magnitude
    Hcontroller Hseparate Hanalog Hfindanalog Hsqrt Hfind Hmath Hbounded Hpad
    Hrawx Hrawy Hbuttons Hprevious Hwx Hwy Hwpressed Hwdown Hwsx Hwsy Hwmag.
  destruct (generated_controller_copy_prefix_executes ge layout le before
    controller pad Int.zero Int.zero buttons previous Hcontroller Hseparate Hpad
    Hrawx Hrawy Hbuttons Hprevious Hwx Hwy Hwpressed Hwdown)
    as (copied & lec & Hprefix & Hrawx' & Hrawy' & Hpressed & Hdown & Hcopyframe &
      Hcontroller' & Haccess & Hvalid).
  destruct (generated_neutral_analog_call_executes ge layout copied controller
    sqrt magnitude Hsqrt Hfind Hmath Hbounded Hrawx' Hrawy'
    (Haccess Mfloat32 controller 4 Writable Hwsx)
    (Haccess Mfloat32 controller 8 Writable Hwsy)
    (Haccess Mfloat32 controller 12 Writable Hwmag))
    as (after & Hcall & Hsx & Hsy & Hmag & Hanalogframe).
  assert (Hvalidcontroller : Mem.valid_block copied controller).
  { eapply Mem.valid_access_valid_block. eapply Mem.valid_access_implies.
    - eapply Mem.load_valid_access. exact Hrawx'.
    - constructor. }
  exists after. eexists. split.
  - eapply controller_prefix_then_analog; [exact Hprefix |].
    cbn [controller_copy_stages generated_connected_controller_branch
      P.f_read_controller_inputs fn_body].
    eapply exec_Scall.
    + reflexivity.
    + analog_expr.
    + analog_arguments.
    + exact Hfindanalog.
    + reflexivity.
    + exact Hcall.
  - do 4 (split; [rewrite Hanalogframe by
      (try exact Hvalidcontroller; unfold playback_read_avoids;
        first [right; left; cbn; lia | right; right; cbn; lia]); eassumption |]).
    split; [exact Hsx |]. split; [exact Hsy |]. split; [exact Hmag |].
    intros chunk b offset Hvb Havoid.
    unfold playback_read_avoids in Havoid.
    rewrite Hanalogframe.
    + apply Hcopyframe; unfold playback_read_avoids;
        destruct Havoid as [H | [H | H]];
        first [left; exact H | right; left; exact H |
          right; left; cbn; lia | right; right; cbn; lia].
    + apply Hvalid. exact Hvb.
    + unfold playback_read_avoids. destruct Havoid as [H | [H | H]];
        first [left; exact H | right; left; exact H |
          right; left; cbn; lia | right; right; cbn; lia].
Qed.

Lemma controller_demo_low_nibble : forall mask,
  Int.and mask (Int.repr 15) = Int.zero_ext 4 mask.
Proof.
  intros mask. symmetry.
  change (Int.zero_ext 4 mask = Int.and mask (Int.repr (two_p 4 - 1))).
  apply Int.zero_ext_and. lia.
Qed.

Lemma controller_demo_decode_add_is_or : forall mask,
  Int.add (Int.shl (Int.and mask (Int.repr 240)) (Int.repr 8))
    (Int.and mask (Int.repr 15)) =
  Int.or (Int.shl (Int.and mask (Int.repr 240)) (Int.repr 8))
    (Int.and mask (Int.repr 15)).
Proof.
  intros mask. apply Int.add_is_or. rewrite controller_demo_low_nibble.
  apply Int.same_bits_eq. intros i Hi.
  rewrite Int.bits_and, Int.bits_shl by exact Hi.
  rewrite Int.bits_zero_ext by lia. rewrite Int.bits_zero.
  change (Int.unsigned (Int.repr 8)) with 8.
  destruct (zlt i 8); [reflexivity |].
  rewrite zlt_false by lia. apply Bool.andb_false_r.
Qed.

Lemma controller_demo_decode_clears_end : forall mask,
  Int.testbit (playback_record_buttons_value mask) 7 = false.
Proof.
  intros mask. unfold playback_record_buttons_value.
  rewrite controller_demo_decode_add_is_or, controller_demo_low_nibble.
  rewrite Int.bits_zero_ext by lia. rewrite zlt_true by lia.
  rewrite Int.bits_or, Int.bits_shl by (cbn; lia).
  rewrite Int.bits_zero_ext by lia.
  change (Int.unsigned (Int.repr 8)) with 8.
  rewrite zlt_true by lia. rewrite zlt_false by lia. reflexivity.
Qed.

Lemma controller_physical_start_bit : forall physical,
  Int.testbit physical 12 = true ->
  Int.testbit (playback_start_button physical) 12 = true /\
  Int.testbit (playback_start_button physical) 7 = false.
Proof.
  intros physical Hstart. unfold playback_start_button, playback_masked_buttons.
  split; repeat first [rewrite Int.bits_zero_ext by lia |
    rewrite zlt_true by lia | rewrite Int.bits_and by (cbn; lia)].
  - change ((Int.testbit physical 12 && true) && true = true)%bool.
    rewrite Hstart. reflexivity.
  - change ((Int.testbit physical 7 && false) && false = false)%bool.
    destruct (Int.testbit physical 7); reflexivity.
Qed.

Definition controller_new_physical_start_claim : Prop :=
  forall physical mask previous,
    Int.testbit physical 12 = true ->
    Int.testbit previous 12 = false ->
    Int.testbit (controller_pressed_value
      (playback_output_buttons physical mask) previous) 12 = true /\
    Int.testbit (controller_pressed_value
      (playback_output_buttons physical mask) previous) 7 = false.

Theorem controller_demo_new_physical_start_sets_pressed_without_end :
  controller_new_physical_start_claim.
Proof.
  unfold controller_new_physical_start_claim.
  intros physical mask previous Hphysical Hprevious.
  destruct (controller_physical_start_bit physical Hphysical) as [Hstart Hend].
  assert (Hnewstart : Int.testbit (playback_output_buttons physical mask) 12 = true).
  { unfold playback_output_buttons. rewrite Int.bits_zero_ext by lia.
    rewrite zlt_true by lia. rewrite Int.bits_or by (cbn; lia).
    rewrite Hstart. apply Bool.orb_true_r. }
  assert (Hnewend : Int.testbit (playback_output_buttons physical mask) 7 = false).
  { unfold playback_output_buttons. rewrite Int.bits_zero_ext by lia.
    rewrite zlt_true by lia. rewrite Int.bits_or by (cbn; lia).
    rewrite controller_demo_decode_clears_end, Hend. reflexivity. }
  unfold controller_pressed_value. split;
    rewrite Int.bits_zero_ext by lia; rewrite zlt_true by lia;
    rewrite Int.bits_and, Int.bits_xor by (cbn; lia).
  - rewrite Hnewstart, Hprevious. reflexivity.
  - rewrite Hnewend. reflexivity.
Qed.

Lemma controller_single_bit_mask_bits : forall bit i,
  0 <= bit < Int.zwordsize -> 0 <= i < Int.zwordsize ->
  Int.testbit (Int.shl Int.one (Int.repr bit)) i = zeq i bit.
Proof.
  intros bit i Hbit Hi. rewrite Int.bits_shl by exact Hi.
  rewrite Int.unsigned_repr by (cbn in *; lia).
  destruct (zlt i bit).
  - destruct (zeq i bit); [lia | reflexivity].
  - rewrite Int.bits_one. destruct (zeq (i-bit) 0), (zeq i bit); try reflexivity; lia.
Qed.

Lemma controller_mask_from_bit : forall word bit flag,
  0 <= bit < Int.zwordsize -> Int.testbit word bit = flag ->
  Int.and word (Int.shl Int.one (Int.repr bit)) =
    if flag then Int.shl Int.one (Int.repr bit) else Int.zero.
Proof.
  intros word bit flag Hbit Hflag. apply Int.same_bits_eq. intros i Hi.
  rewrite Int.bits_and by exact Hi.
  rewrite controller_single_bit_mask_bits by assumption.
  destruct flag.
  - rewrite controller_single_bit_mask_bits by assumption.
    destruct (zeq i bit); [subst; rewrite Hflag; reflexivity |].
    apply Bool.andb_false_r.
  - rewrite Int.bits_zero. destruct (zeq i bit).
    + subst. rewrite Hflag. reflexivity.
    + apply Bool.andb_false_r.
Qed.

Definition controller_new_physical_start_guards_claim : Prop :=
  forall physical mask previous,
    Int.testbit physical 12 = true ->
    Int.testbit previous 12 = false ->
    Int.eq (Int.and (controller_pressed_value
      (playback_output_buttons physical mask) previous) (Int.repr 4096)) Int.zero = false /\
    Int.eq (Int.and (controller_pressed_value
      (playback_output_buttons physical mask) previous) (Int.repr 128)) Int.zero = true.

Theorem controller_new_physical_start_satisfies_actual_guards :
  controller_new_physical_start_guards_claim.
Proof.
  unfold controller_new_physical_start_guards_claim.
  intros physical mask previous Hphysical Hprevious.
  destruct (controller_demo_new_physical_start_sets_pressed_without_end
    physical mask previous Hphysical Hprevious) as [Hstart Hend].
  pose proof (controller_mask_from_bit
    (controller_pressed_value (playback_output_buttons physical mask) previous)
    12 true ltac:(cbn; lia) Hstart) as Hstartmask.
  pose proof (controller_mask_from_bit
    (controller_pressed_value (playback_output_buttons physical mask) previous)
    7 false ltac:(cbn; lia) Hend) as Hendmask.
  change (Int.shl Int.one (Int.repr 12)) with (Int.repr 4096) in Hstartmask.
  change (Int.shl Int.one (Int.repr 7)) with (Int.repr 128) in Hendmask.
  cbn in Hstartmask, Hendmask. rewrite Hstartmask, Hendmask. split; reflexivity.
Qed.

Definition demo_controller_input_execution_claim_us_jp : Prop :=
  controller_connected_neutral_claim (fn_body P.f_read_controller_inputs) /\
  controller_connected_neutral_claim (fn_body jp_game_init.f_read_controller_inputs) /\
  controller_new_physical_start_claim /\ controller_new_physical_start_guards_claim.

Theorem generated_demo_controller_input_execution_us_jp :
  demo_controller_input_execution_claim_us_jp.
Proof.
  split; [exact generated_connected_neutral_controller_executes |].
  split; [exact generated_connected_neutral_controller_executes |].
  split; [exact controller_demo_new_physical_start_sets_pressed_without_end |].
  exact controller_new_physical_start_satisfies_actual_guards.
Qed.
