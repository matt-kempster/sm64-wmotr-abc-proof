From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
 Ctypes Errors Events Floats Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoPlaybackExecution
 DemoControllerInputExecution DemoControllerCopyExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

Ltac second_expr :=
 lazymatch goal with
 | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
 | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
   eapply eval_Etempvar; cbn [set_opttemp]; repeat rewrite PTree.gsspec; cbn;
   first [reflexivity|eassumption]
 | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
   eapply eval_Eunop; [second_expr|analog_normalize]
 | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
   eapply eval_Ebinop; [second_expr|second_expr|analog_normalize]
 | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
   eapply eval_Ecast; [second_expr|analog_normalize]
 | |- eval_expr _ _ _ _ _ _ => eapply eval_Elvalue;
   [second_lvalue|
    first [eapply deref_loc_value; [reflexivity|cbn; controller_copy_load]|
     eapply deref_loc_reference; reflexivity|eapply deref_loc_copy; reflexivity]]
 end
with second_lvalue :=
 lazymatch goal with
 | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
   eapply eval_Evar_global; [first [reflexivity|eassumption]|eassumption]
 | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; second_expr
 | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
   eapply eval_Efield_struct; [second_expr|reflexivity|eassumption|eassumption]
 end.
Ltac second_arguments :=
 first [apply eval_Enil|eapply eval_Econs; [second_expr|analog_normalize|second_arguments]].
Ltac second_stmt :=
 lazymatch goal with
 | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
   eapply exec_Sseq_1 with (t1:=E0) (t2:=E0); [second_stmt|second_stmt]
 | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; second_expr
 | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
   eapply exec_Sassign; [second_lvalue|second_expr|analog_normalize|
     eapply assign_loc_value; [reflexivity|cbn -[Float32.of_int controller_float_zero];
      lazymatch goal with |- Mem.store ?chunk ?m ?b ?ofs ?v = ?out =>
       let actual:=eval vm_compute in ofs in change(Mem.store chunk m b actual v=out)
      end; eassumption]]
 | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
   first [eapply exec_Sifthenelse with(v1:=Vzero)(b:=false);
     [second_expr|reflexivity|second_stmt]|
    eapply exec_Sifthenelse with(v1:=Vint Int.one)(b:=true);
     [second_expr|reflexivity|second_stmt]]
 | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
 | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
   eapply exec_Scall; [reflexivity|second_expr|second_arguments|
    cbn; eassumption|reflexivity|eapply eval_funcall_external; eassumption]
 end.
Theorem generated_second_neutral_analog_body_executes :
  forall ge (layout : controller_input_layout ge) e le before controller sqrt magnitude,
    e ! P._sqrtf = None ->
    le ! P._controller = Some (Vptr controller (Ptrofs.repr 28)) ->
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle controller_zero_magnitude_argument] m E0 (Vsingle magnitude) m) ->
    Float32.cmp Cgt magnitude (Float32.of_int (Int.repr 64)) = false ->
    Mem.load Mint16signed before controller 28 = Some Vzero ->
    Mem.load Mint16signed before controller 30 = Some Vzero ->
    Mem.valid_access before Mfloat32 controller 32 Writable ->
    Mem.valid_access before Mfloat32 controller 36 Writable ->
    Mem.valid_access before Mfloat32 controller 40 Writable ->
    exists after le',
      exec_stmt function_entry2 ge e le before
        (fn_body P.f_adjust_analog_stick) E0 le' after Out_normal /\
      Mem.load Mfloat32 after controller 32 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 36 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 40 = Some (Vsingle magnitude) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset controller 32 44 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      (forall b offset kind perm,
        Mem.perm before b offset kind perm -> Mem.perm after b offset kind perm) /\
      Mem.unchanged_on (controller_outside_bytes controller 32 44) before after.
Proof.
  intros ge layout e le before controller sqrt magnitude Hlocal Hcontroller Hsqrt Hfind
    Hmath Hbounded Hrawx Hrawy Hwx Hwy Hwm.
  destruct layout as [layout Hraw_x Hraw_y Hstick_x Hstick_y Hstick_mag Hdown Hpressed].
  destruct layout as [controller_co pad_co record_co Hcontroller_co Hpad_co Hrecord_co
    Hcontroller_size Hdata Hbutton Hx Hy Htimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  cbn in Hraw_x, Hraw_y, Hstick_x, Hstick_y, Hstick_mag, Hdown, Hpressed.
  destruct (Mem.valid_access_store before Mfloat32 controller 32
    (Vsingle controller_float_zero) Hwx) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mfloat32 controller 36
    (Vsingle controller_float_zero) ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mfloat32 controller 40
    (Vsingle magnitude) ltac:(demo_access)) as [after Hs3].
  assert (Hrawx2 : Mem.load Mint16signed m2 controller 28 = Some Vzero) by playback_load.
  assert (Hrawy2 : Mem.load Mint16signed m2 controller 30 = Some Vzero) by playback_load.
  assert (Hx2 : Mem.load Mfloat32 m2 controller 32 = Some (Vsingle controller_float_zero)) by playback_load.
  assert (Hy2 : Mem.load Mfloat32 m2 controller 36 = Some (Vsingle controller_float_zero)) by playback_load.
  assert (Hmag3 : Mem.load Mfloat32 after controller 40 = Some (Vsingle magnitude)) by playback_load.
  pose proof (Hmath m2) as Hsqrtcall.
  exists after. eexists. split.
  - unfold controller_float_zero, controller_zero_magnitude_argument,
      controller_sqrt_fundef, controller_sqrt_external in *.
    cbn [P.f_adjust_analog_stick fn_body]. second_stmt.
  - do 3 (split; [playback_load|]). split.
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
    + split.
      * intros b offset kind perm Hperm.
        eapply Mem.perm_store_1; [exact Hs3 |].
        eapply Mem.perm_store_1; [exact Hs2 |].
        eapply Mem.perm_store_1; eassumption.
      * controller_copy_frame.
Qed.

Definition second_analog_temps (controller:block) : temp_env :=
 PTree.set P._controller (Vptr controller (Ptrofs.repr 28))
   (create_undef_temps (fn_temps P.f_adjust_analog_stick)).
Theorem generated_second_neutral_analog_call_executes :
  forall ge (layout : controller_input_layout ge) before controller sqrt magnitude,
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle controller_zero_magnitude_argument] m E0 (Vsingle magnitude) m) ->
    Float32.cmp Cgt magnitude (Float32.of_int (Int.repr 64)) = false ->
    Mem.load Mint16signed before controller 28 = Some Vzero ->
    Mem.load Mint16signed before controller 30 = Some Vzero ->
    Mem.valid_access before Mfloat32 controller 32 Writable ->
    Mem.valid_access before Mfloat32 controller 36 Writable ->
    Mem.valid_access before Mfloat32 controller 40 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal P.f_adjust_analog_stick)
        [Vptr controller (Ptrofs.repr 28)] E0 after Vundef /\
      Mem.load Mfloat32 after controller 32 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 36 = Some (Vsingle controller_float_zero) /\
      Mem.load Mfloat32 after controller 40 = Some (Vsingle magnitude) /\
      (forall chunk b offset,
        Mem.valid_block before b ->
        playback_read_avoids chunk b offset controller 32 44 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      (forall b offset kind permission,
        Mem.valid_block before b -> Mem.perm before b offset kind permission ->
        Mem.perm after b offset kind permission) /\
      (forall chunk b offset permission, Mem.valid_access before chunk b offset permission ->
        Mem.valid_access after chunk b offset permission) /\
      Mem.unchanged_on (controller_outside_bytes controller 32 44) before after.
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
      [Vptr controller (Ptrofs.repr 28)] before (controller_analog_env filler)
      (second_analog_temps controller) allocated).
  { apply function_entry2_intro.
    - constructor; [cbn; tauto | constructor].
    - constructor; [cbn; tauto | constructor].
    - vm_compute. intuition congruence.
    - eapply alloc_variables_cons with (m1 := allocated) (b1 := filler).
      + change (Mem.alloc before 0 8 = (allocated, filler)). exact Ha.
      + constructor.
    - reflexivity. }
  destruct (generated_second_neutral_analog_body_executes ge layout
    (controller_analog_env filler) (second_analog_temps controller) allocated
    controller sqrt magnitude ltac:(reflexivity)
    ltac:(unfold second_analog_temps; rewrite PTree.gss; reflexivity)
    Hsqrt Hfind Hmath Hbounded
    ltac:(eapply Mem.load_alloc_other; eassumption)
    ltac:(eapply Mem.load_alloc_other; eassumption)
    ltac:(eapply Mem.valid_access_alloc_other; eassumption)
    ltac:(eapply Mem.valid_access_alloc_other; eassumption)
    ltac:(eapply Mem.valid_access_alloc_other; eassumption))
    as (called & le' & Hbody & Hx & Hy & Hmag & Hframe & Hperm & Hbytes).
  destruct (Mem.range_perm_free called filler 0 8
    ltac:(intros offset Hrange; apply Hperm;
      eapply Mem.perm_alloc_2; eassumption)) as [after Hfree].
  assert (Hpermissions : forall b offset kind permission,
      Mem.valid_block before b -> Mem.perm before b offset kind permission ->
      Mem.perm after b offset kind permission).
  { intros b offset kind permission Hvalid Hpermission.
    assert (Hbf : b <> filler).
    { intros ->. exact (Mem.fresh_block_alloc _ _ _ _ _ Ha Hvalid). }
    eapply Mem.perm_free_1; [exact Hfree | left; exact Hbf |].
    apply Hperm. eapply Mem.perm_alloc_1; eassumption. }
  exists after. split.
  - eapply eval_funcall_internal with (e := controller_analog_env filler)
      (le1 := second_analog_temps controller) (le2 := le')
      (m1 := allocated) (m2 := called) (out := Out_normal).
    + exact Hentry.
    + exact Hbody.
    + reflexivity.
    + change (Mem.free_list called [(filler, 0, 8)] = Some after).
      cbn. rewrite Hfree. reflexivity.
  - split; [rewrite (Mem.load_free _ _ _ _ _ Hfree) by (left; exact Hdistinct); exact Hx |].
    split; [rewrite (Mem.load_free _ _ _ _ _ Hfree) by (left; exact Hdistinct); exact Hy |].
    split; [rewrite (Mem.load_free _ _ _ _ _ Hfree) by (left; exact Hdistinct); exact Hmag |]. split.
    + intros chunk b offset Hvalid Havoid.
      assert (Hbf : b <> filler).
      { intros ->. exact (Mem.fresh_block_alloc _ _ _ _ _ Ha Hvalid). }
      rewrite (Mem.load_free _ _ _ _ _ Hfree) by (left; exact Hbf).
      rewrite Hframe by exact Havoid.
      exact (Mem.load_alloc_unchanged _ _ _ _ _ Ha chunk b offset Hvalid).
    + split; [exact Hpermissions |].
      split.
      * intros chunk b offset permission [Hrange Halign]. split; [|exact Halign].
        intros address Haddress. apply Hpermissions.
        -- eapply Mem.valid_access_valid_block.
           eapply Mem.valid_access_implies; [split; [exact Hrange | exact Halign] | constructor].
        -- apply Hrange. exact Haddress.
      * apply Mem.unchanged_on_implies with
          (P:=fun b byte => Mem.valid_block before b /\ controller_outside_bytes controller 32 44 b byte).
        -- eapply Mem.unchanged_on_trans with (m2:=allocated).
           ++ eapply Mem.alloc_unchanged_on; exact Ha.
           ++ eapply Mem.unchanged_on_trans with (m2:=called).
              ** eapply Mem.unchanged_on_implies; [exact Hbytes|]. intros b byte [_ Houtside] Hvb.
                 exact Houtside.
              ** eapply Mem.free_unchanged_on; [exact Hfree|].
                 intros byte Hrange [Hvalid Houtside].
                 exact (Mem.fresh_block_alloc _ _ _ _ _ Ha Hvalid).
        -- intros b byte Houtside Hvalid. split; assumption.
Qed.

Theorem generated_second_controller_copy_prefix_executes :
  forall ge (layout : controller_input_layout ge) le before
      controller pad rawx rawy buttons previous,
    le ! P._controller = Some (Vptr controller (Ptrofs.repr 28)) ->
    controller <> pad ->
    Mem.load Mptr before controller 52 = Some (Vptr pad (Ptrofs.repr 6)) ->
    Mem.load Mint8signed before pad 8 = Some (Vint rawx) ->
    Mem.load Mint8signed before pad 9 = Some (Vint rawy) ->
    Mem.load Mint16unsigned before pad 6 = Some (Vint buttons) ->
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
  destruct (Mem.valid_access_store before Mint16signed controller 28 (Vint rawx)
    Hwx) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint16signed controller 30 (Vint rawy)
    ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint16unsigned controller 46
    (Vint (controller_pressed_value buttons previous)) ltac:(demo_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint16unsigned controller 44 (Vint buttons)
    ltac:(demo_access)) as [after Hs4].
  assert (Hpad1 : Mem.load Mptr m1 controller 52 = Some (Vptr pad (Ptrofs.repr 6))) by controller_copy_load.
  assert (Hpad2 : Mem.load Mptr m2 controller 52 = Some (Vptr pad (Ptrofs.repr 6))) by controller_copy_load.
  assert (Hpad3 : Mem.load Mptr m3 controller 52 = Some (Vptr pad (Ptrofs.repr 6))) by controller_copy_load.
  assert (Hprevious2 : Mem.load Mint16unsigned m2 controller 44 = Some (Vint previous)) by controller_copy_load.
  assert (Hbuttons2 : Mem.load Mint16unsigned m2 pad 6 = Some (Vint buttons)) by controller_copy_load.
  assert (Hbuttons3 : Mem.load Mint16unsigned m3 pad 6 = Some (Vint buttons)) by controller_copy_load.
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
      * eapply exec_Sset. second_expr.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset. second_expr.
        -- second_stmt.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset. second_expr.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset. second_expr.
           ++ second_stmt.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- second_stmt.
        -- second_stmt.
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

Lemma second_controller_neutral_pressed : forall previous,
 controller_pressed_value Int.zero previous = Int.zero.
Proof.
 intros previous. unfold controller_pressed_value.
 rewrite Int.and_commut, Int.and_zero. reflexivity.
Qed.

Definition demo_second_controller_execution_claim : Prop :=
 forall ge (layout:controller_input_layout ge) (us:bool) le before
   controllers pads analog sqrt previous magnitude,
 le ! P._controller = Some (Vptr controllers (Ptrofs.repr 28)) ->
 controllers <> pads ->
 Genv.find_symbol ge P._adjust_analog_stick = Some analog ->
 Genv.find_funct ge (Vptr analog Ptrofs.zero) = Some (Internal P.f_adjust_analog_stick) ->
 Genv.find_symbol ge P._sqrtf = Some sqrt ->
 Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
 (forall m, external_call controller_sqrt_external ge
   [Vsingle controller_zero_magnitude_argument] m E0 (Vsingle magnitude) m) ->
 Float32.cmp Cgt magnitude (Float32.of_int (Int.repr 64)) = false ->
 Mem.load Mptr before controllers 52 = Some (Vptr pads (Ptrofs.repr 6)) ->
 Mem.weak_valid_pointer before pads (Ptrofs.unsigned (Ptrofs.repr 6)) = true ->
 Mem.load Mint8signed before pads 8 = Some Vzero ->
 Mem.load Mint8signed before pads 9 = Some Vzero ->
 Mem.load Mint16unsigned before pads 6 = Some Vzero ->
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

Theorem generated_second_connected_neutral_controller_executes_us_jp :
 demo_second_controller_execution_claim.
Proof.
 intros ge layout us le before controllers pads analog sqrt previous magnitude Hcontroller Hseparate
   Hanalog Hfindanalog Hsqrt Hfind Hmath Hbounded Hpad Hvalidpad Hrawx Hrawy Hbuttons Hprevious
   Hwx Hwy Hwpressed Hwdown Hwsx Hwsy Hwmag.
 set (guarded:=PTree.set P._t'22 (Vptr pads (Ptrofs.repr 6)) le).
 assert (Hguarded_controller : guarded ! P._controller = Some (Vptr controllers (Ptrofs.repr 28))).
 { unfold guarded. rewrite PTree.gso by discriminate. exact Hcontroller. }
 destruct (generated_second_controller_copy_prefix_executes ge layout guarded before
   controllers pads Int.zero Int.zero Int.zero previous Hguarded_controller Hseparate Hpad
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
     destruct layout. cbn in *. second_expr.
   + eapply exec_Sifthenelse with (v1:=Vint Int.one) (b:=true).
     * eapply eval_Ebinop with (v1:=Vptr pads (Ptrofs.repr 6)) (v2:=Vzero).
       -- eapply eval_Etempvar. unfold guarded. apply PTree.gss.
       -- eapply eval_Ecast; [constructor|reflexivity].
       -- change (option_map Val.of_bool
            (if Mem.weak_valid_pointer before pads (Ptrofs.unsigned (Ptrofs.repr 6))
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
