From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop Ctypes
  Errors Events Floats Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoPlaybackExecution DemoControllerInputExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

Inductive analog_direction : Type := Xnegative | Xpositive | Ynegative | Ypositive.
Definition direction_raw_offset (d : analog_direction) : Z :=
  match d with Xnegative | Xpositive => 0 | _ => 2 end.
Definition direction_float_offset (d : analog_direction) : Z :=
  match d with Xnegative | Xpositive => 4 | _ => 8 end.
Definition direction_flag (d : analog_direction) (raw : int) : bool :=
  match d with
  | Xnegative | Ynegative => Int.cmp Cle raw (Int.neg (Int.repr 8))
  | _ => Int.cmp Cge raw (Int.repr 8)
  end.
Definition direction_float_value (d : analog_direction) (raw : int) : float32 :=
  Float32.of_int
    (match d with Xnegative | Ynegative => Int.add raw (Int.repr 6)
     | _ => Int.sub raw (Int.repr 6) end).
Definition actual_analog_direction (d : analog_direction) : statement :=
  match fn_body P.f_adjust_analog_stick with
  | Ssequence _ (Ssequence _ (Ssequence xl
      (Ssequence xh (Ssequence yl (Ssequence yh _))))) =>
      match d with Xnegative => xl | Xpositive => xh | Ynegative => yl | Ypositive => yh end
  | _ => Sskip
  end.

Lemma optional_float_store : forall before controller offset (flag : bool) (value previous : float32),
  Mem.valid_access before Mfloat32 controller offset Writable ->
  Mem.load Mfloat32 before controller offset = Some (Vsingle previous) ->
  exists after,
    (if flag then Mem.store Mfloat32 before controller offset (Vsingle value) = Some after
     else after = before) /\
    Mem.load Mfloat32 after controller offset = Some (Vsingle (if flag then value else previous)) /\
    (forall chunk b ofs,
      playback_read_avoids chunk b ofs controller offset (offset+4) ->
      Mem.load chunk after b ofs = Mem.load chunk before b ofs) /\
    (forall b ofs kind permission,
      Mem.perm before b ofs kind permission -> Mem.perm after b ofs kind permission).
Proof.
  intros before controller offset flag value previous Haccess Hload. destruct flag.
  - destruct (Mem.valid_access_store before Mfloat32 controller offset (Vsingle value)
      Haccess) as [after Hstore]. exists after. split; [exact Hstore |].
    split.
    + rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore). reflexivity.
    + split.
      * intros chunk b ofs Havoid. apply (Mem.load_store_other _ _ _ _ _ _ Hstore).
        destruct Havoid as [H | [H | H]]; [left; exact H | right; left; exact H | right; right; exact H].
      * intros b ofs kind permission Hperm. eapply Mem.perm_store_1; eassumption.
  - exists before. repeat split; intros; try assumption; reflexivity.
Qed.

Ltac analog_normalize ::=
  first
  [match goal with
   | H : Int.cmp ?comparison ?x ?y = ?flag |- _ = ?out =>
       change (Some (Val.of_bool (Int.cmp comparison x y)) = out); rewrite H; reflexivity
   | H : Float32.cmp ?comparison ?x ?y = ?flag |- _ = ?out =>
       change (Some (Val.of_bool (Float32.cmp comparison x y)) = out); rewrite H; reflexivity
   end
  |cbn -[Int.sign_ext Int.zero_ext Int.repr Ptrofs.repr Ptrofs.add Ptrofs.mul
     Ptrofs.of_ints Float32.of_int Float32.mul Float32.div Float32.add Float32.cmp];
   repeat match goal with
   | H : (genv_cenv ?ge) ! ?id = Some ?co |-
       context [match (genv_cenv ?ge) ! ?id with _ => _ end] => rewrite H
   | H : co_sizeof ?co = _ |- context [co_sizeof ?co] => rewrite H
   end;
   cbn -[Int.sign_ext Int.zero_ext Int.repr Float32.of_int Float32.mul Float32.div Float32.add Float32.cmp];
   repeat match goal with
   | H : Int.sign_ext ?bits ?value = ?value |- context [Int.sign_ext ?bits ?value] => rewrite H
   | H : Int.zero_ext ?bits ?value = ?value |- context [Int.zero_ext ?bits ?value] => rewrite H
   end;
   repeat rewrite Int.zero_ext_idem by lia;
   repeat rewrite Int.sign_ext_idem by lia;
   repeat rewrite Ptrofs.add_zero; reflexivity].

Theorem actual_analog_direction_executes :
  forall d ge (layout : controller_input_layout ge) e le before after controller raw,
    le ! P._controller = Some (Vptr controller Ptrofs.zero) ->
    Mem.load Mint16signed before controller (direction_raw_offset d) = Some (Vint raw) ->
    (if direction_flag d raw then
      Mem.store Mfloat32 before controller (direction_float_offset d)
        (Vsingle (direction_float_value d raw)) = Some after else after = before) ->
    exists le',
      exec_stmt function_entry2 ge e le before (actual_analog_direction d)
        E0 le' after Out_normal /\
      le' ! P._controller = Some (Vptr controller Ptrofs.zero).
Proof.
  intros d ge layout e le before after controller raw Hcontroller Hraw Hstore.
  destruct layout as [layout Hraw_x Hraw_y Hstick_x Hstick_y Hstick_mag Hdown Hpressed].
  destruct layout as [controller_co pad_co record_co Hcontroller_co Hpad_co Hrecord_co
    Hcontroller_size Hdata Hbutton Hx Hy Htimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  cbn in Hraw_x, Hraw_y, Hstick_x, Hstick_y, Hstick_mag, Hdown, Hpressed.
  pose proof (Mem.load_cast _ _ _ _ _ Hraw) as Hnormal.
  cbn in Hnormal. assert (Hcast : Int.sign_ext 16 raw = raw) by congruence.
  destruct d.
  all: unfold direction_flag in Hstore;
    match type of Hstore with context [if ?flag then _ else _] => destruct flag eqn:Hflag end.
  all: unfold direction_raw_offset, direction_float_offset, direction_float_value in *;
    cbn -[Float32.of_int Int.add Int.sub Int.repr] in Hstore, Hraw.
  all: try subst after.
  all: eexists; split.
  all: try (unfold actual_analog_direction; cbn [P.f_adjust_analog_stick fn_body]; analog_stmt).
  all: try (cbn; repeat rewrite PTree.gsspec; cbn; exact Hcontroller).
Qed.

Lemma analog_permissions_access : forall before after,
  (forall b ofs kind permission, Mem.perm before b ofs kind permission ->
    Mem.perm after b ofs kind permission) ->
  forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission.
Proof.
  intros before after Hperm chunk b ofs permission [Hrange Halign].
  split; [|exact Halign]. intros address Haddress. apply Hperm. apply Hrange. exact Haddress.
Qed.

Ltac arbitrary_analog_access :=
  first [assumption |
    lazymatch goal with
    | |- Mem.valid_access ?m _ _ _ _ =>
      match goal with H : Mem.store _ _ _ _ _ = Some m |- _ =>
        eapply Mem.store_valid_access_1; [exact H | arbitrary_analog_access] end
    end |
    lazymatch goal with
    | |- Mem.valid_access ?m _ _ _ _ =>
      match goal with
      | H : forall b ofs kind permission, Mem.perm ?old b ofs kind permission ->
          Mem.perm m b ofs kind permission |- _ =>
        eapply analog_permissions_access; [exact H | arbitrary_analog_access]
      end
    end].

Ltac arbitrary_analog_load :=
  first [eassumption | playback_load |
    lazymatch goal with
    | |- Mem.load _ ?m _ _ = _ =>
      match goal with
      | H : forall chunk b ofs, playback_read_avoids chunk b ofs _ _ _ ->
          Mem.load chunk m b ofs = Mem.load chunk ?old b ofs |- _ =>
        rewrite H by (unfold playback_read_avoids;
          first [left; congruence | right; left; cbn; lia | right; right; cbn; lia]);
        arbitrary_analog_load
      end
    end].

Definition arbitrary_analog_axis (raw : int) : float32 :=
  if direction_flag Xpositive raw then direction_float_value Xpositive raw
  else if direction_flag Xnegative raw then direction_float_value Xnegative raw
       else controller_float_zero.
Definition arbitrary_analog_square_sum (rawx rawy : int) : float32 :=
  Float32.add
    (Float32.mul (arbitrary_analog_axis rawx) (arbitrary_analog_axis rawx))
    (Float32.mul (arbitrary_analog_axis rawy) (arbitrary_analog_axis rawy)).
Definition arbitrary_analog_cap (magnitude : float32) : bool :=
  Float32.cmp Cgt magnitude (Float32.of_int (Int.repr 64)).
Definition arbitrary_analog_final_axis (raw : int) (magnitude : float32) : float32 :=
  if arbitrary_analog_cap magnitude then Float32.mul (arbitrary_analog_axis raw)
    (Float32.div (Float32.of_int (Int.repr 64)) magnitude)
  else arbitrary_analog_axis raw.
Definition arbitrary_analog_final_magnitude (magnitude : float32) : float32 :=
  if arbitrary_analog_cap magnitude then Float32.of_int (Int.repr 64) else magnitude.

Lemma analog_avoid_float_field : forall chunk b offset controller field,
  4 <= field -> field + 4 <= 16 ->
  playback_read_avoids chunk b offset controller 4 16 ->
  playback_read_avoids chunk b offset controller field (field + 4).
Proof. unfold playback_read_avoids. intros; intuition lia. Qed.

Theorem generated_arbitrary_analog_body_executes :
  forall ge (layout : controller_input_layout ge) e le before controller sqrt rawx rawy magnitude,
    e ! P._sqrtf = None ->
    le ! P._controller = Some (Vptr controller Ptrofs.zero) ->
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle (arbitrary_analog_square_sum rawx rawy)] m E0 (Vsingle magnitude) m) ->
    Mem.load Mint16signed before controller 0 = Some (Vint rawx) ->
    Mem.load Mint16signed before controller 2 = Some (Vint rawy) ->
    Mem.valid_access before Mfloat32 controller 4 Writable ->
    Mem.valid_access before Mfloat32 controller 8 Writable ->
    Mem.valid_access before Mfloat32 controller 12 Writable ->
    exists after le',
      exec_stmt function_entry2 ge e le before
        (fn_body P.f_adjust_analog_stick) E0 le' after Out_normal /\
      Mem.load Mfloat32 after controller 4 = Some (Vsingle (arbitrary_analog_final_axis rawx magnitude)) /\
      Mem.load Mfloat32 after controller 8 = Some (Vsingle (arbitrary_analog_final_axis rawy magnitude)) /\
      Mem.load Mfloat32 after controller 12 = Some (Vsingle (arbitrary_analog_final_magnitude magnitude)) /\
      (forall chunk b offset,
        playback_read_avoids chunk b offset controller 4 16 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      (forall b offset kind perm,
        Mem.perm before b offset kind perm -> Mem.perm after b offset kind perm).
Proof.
  intros ge layout e le before controller sqrt rawx rawy magnitude Hlocal Hcontroller
    Hsqrt Hfind Hmath Hrawx Hrawy Hwx Hwy Hwm.
  destruct (Mem.valid_access_store before Mfloat32 controller 4
    (Vsingle controller_float_zero) Hwx) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mfloat32 controller 8
    (Vsingle controller_float_zero) ltac:(demo_access)) as [m2 Hs2].
  assert (Hx2 : Mem.load Mfloat32 m2 controller 4 = Some (Vsingle controller_float_zero)) by playback_load.
  assert (Hy2 : Mem.load Mfloat32 m2 controller 8 = Some (Vsingle controller_float_zero)) by playback_load.
  destruct (optional_float_store m2 controller 4 (direction_flag Xnegative rawx)
    (direction_float_value Xnegative rawx) controller_float_zero
    ltac:(arbitrary_analog_access) Hx2) as (m3 & Hs3 & Hx3 & Hf3 & Hp3).
  destruct (optional_float_store m3 controller 4 (direction_flag Xpositive rawx)
    (direction_float_value Xpositive rawx)
    (if direction_flag Xnegative rawx then direction_float_value Xnegative rawx else controller_float_zero)
    ltac:(arbitrary_analog_access) Hx3) as (m4 & Hs4 & Hx4 & Hf4 & Hp4).
  assert (Hy4 : Mem.load Mfloat32 m4 controller 8 = Some (Vsingle controller_float_zero))
    by arbitrary_analog_load.
  destruct (optional_float_store m4 controller 8 (direction_flag Ynegative rawy)
    (direction_float_value Ynegative rawy) controller_float_zero
    ltac:(arbitrary_analog_access) Hy4) as (m5 & Hs5 & Hy5 & Hf5 & Hp5).
  destruct (optional_float_store m5 controller 8 (direction_flag Ypositive rawy)
    (direction_float_value Ypositive rawy)
    (if direction_flag Ynegative rawy then direction_float_value Ynegative rawy else controller_float_zero)
    ltac:(arbitrary_analog_access) Hy5) as (m6 & Hs6 & Hy6 & Hf6 & Hp6).
  assert (Hx6 : Mem.load Mfloat32 m6 controller 4 = Some (Vsingle (arbitrary_analog_axis rawx))).
  { unfold arbitrary_analog_axis. arbitrary_analog_load. }
  assert (Hy6' : Mem.load Mfloat32 m6 controller 8 = Some (Vsingle (arbitrary_analog_axis rawy))).
  { exact Hy6. }
  destruct (Mem.valid_access_store m6 Mfloat32 controller 12 (Vsingle magnitude)
    ltac:(arbitrary_analog_access)) as [m7 Hs7].
  assert (Hx7 : Mem.load Mfloat32 m7 controller 4 = Some (Vsingle (arbitrary_analog_axis rawx)))
    by arbitrary_analog_load.
  assert (Hy7 : Mem.load Mfloat32 m7 controller 8 = Some (Vsingle (arbitrary_analog_axis rawy)))
    by arbitrary_analog_load.
  assert (Hmag7 : Mem.load Mfloat32 m7 controller 12 = Some (Vsingle magnitude))
    by arbitrary_analog_load.
  destruct (optional_float_store m7 controller 4 (arbitrary_analog_cap magnitude)
    (Float32.mul (arbitrary_analog_axis rawx) (Float32.div (Float32.of_int (Int.repr 64)) magnitude))
    (arbitrary_analog_axis rawx) ltac:(arbitrary_analog_access) Hx7)
    as (m8 & Hs8 & Hx8 & Hf8 & Hp8).
  assert (Hy8 : Mem.load Mfloat32 m8 controller 8 = Some (Vsingle (arbitrary_analog_axis rawy)))
    by arbitrary_analog_load.
  assert (Hmag8 : Mem.load Mfloat32 m8 controller 12 = Some (Vsingle magnitude))
    by arbitrary_analog_load.
  destruct (optional_float_store m8 controller 8 (arbitrary_analog_cap magnitude)
    (Float32.mul (arbitrary_analog_axis rawy) (Float32.div (Float32.of_int (Int.repr 64)) magnitude))
    (arbitrary_analog_axis rawy) ltac:(arbitrary_analog_access) Hy8)
    as (m9 & Hs9 & Hy9 & Hf9 & Hp9).
  assert (Hmag9 : Mem.load Mfloat32 m9 controller 12 = Some (Vsingle magnitude))
    by arbitrary_analog_load.
  destruct (optional_float_store m9 controller 12 (arbitrary_analog_cap magnitude)
    (Float32.of_int (Int.repr 64)) magnitude ltac:(arbitrary_analog_access) Hmag9)
    as (after & Hs10 & Hmag10 & Hf10 & Hp10).
  destruct (actual_analog_direction_executes Xnegative ge layout e le m2 m3 controller rawx
    Hcontroller ltac:(arbitrary_analog_load) Hs3) as [le3 [Hex3 Hle3]].
  destruct (actual_analog_direction_executes Xpositive ge layout e le3 m3 m4 controller rawx
    Hle3 ltac:(arbitrary_analog_load) Hs4) as [le4 [Hex4 Hle4]].
  destruct (actual_analog_direction_executes Ynegative ge layout e le4 m4 m5 controller rawy
    Hle4 ltac:(arbitrary_analog_load) Hs5) as [le5 [Hex5 Hle5]].
  destruct (actual_analog_direction_executes Ypositive ge layout e le5 m5 m6 controller rawy
    Hle5 ltac:(arbitrary_analog_load) Hs6) as [le6 [Hex6 Hle6]].
  pose proof (Hmath m6) as Hsqrtcall.
  destruct layout as [layout Hraw_x Hraw_y Hstick_x Hstick_y Hstick_mag Hdown Hpressed].
  destruct layout as [controller_co pad_co record_co Hcontroller_co Hpad_co Hrecord_co
    Hcontroller_size Hdata Hbutton Hx Hy Htimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
  cbn in Hraw_x, Hraw_y, Hstick_x, Hstick_y, Hstick_mag, Hdown, Hpressed.
  set (lemath := PTree.set P._t'1 (Vsingle magnitude)
    (PTree.set P._t'10 (Vsingle (arbitrary_analog_axis rawy))
    (PTree.set P._t'9 (Vsingle (arbitrary_analog_axis rawy))
    (PTree.set P._t'8 (Vsingle (arbitrary_analog_axis rawx))
    (PTree.set P._t'7 (Vsingle (arbitrary_analog_axis rawx)) le6))))).
  set (lecap := PTree.set P._t'2 (Vsingle magnitude) lemath).
  exists after. exists (if arbitrary_analog_cap magnitude then
    PTree.set P._t'4 (Vsingle magnitude)
    (PTree.set P._t'3 (Vsingle (arbitrary_analog_axis rawy))
    (PTree.set P._t'6 (Vsingle magnitude)
    (PTree.set P._t'5 (Vsingle (arbitrary_analog_axis rawx)) lecap))) else lecap). split.
  - cbn [P.f_adjust_analog_stick fn_body].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [analog_stmt |].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [analog_stmt |].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hex3 |].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hex4 |].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hex5 |].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hex6 |].
    unfold arbitrary_analog_cap in Hs8, Hs9, Hs10.
    unfold arbitrary_analog_square_sum, controller_sqrt_fundef, controller_sqrt_external in Hsqrtcall, Hfind.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [analog_stmt |].
        eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [analog_stmt |].
        eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [analog_stmt |].
        eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [analog_stmt |].
        eapply exec_Scall;
          [reflexivity | analog_expr | analog_arguments |
           cbn; eassumption | reflexivity |
           eapply eval_funcall_external; eassumption].
      * analog_stmt.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [analog_stmt |].
      unfold arbitrary_analog_cap. unfold lecap, lemath.
      destruct (Float32.cmp Cgt magnitude (Float32.of_int (Int.repr 64))) eqn:Hcap.
      all: cbn in Hs8, Hs9, Hs10; try subst m8; try subst m9; try subst after.
      all: analog_stmt.
  - split; [unfold arbitrary_analog_final_axis; arbitrary_analog_load |].
    split; [unfold arbitrary_analog_final_axis; arbitrary_analog_load |].
    split; [exact Hmag10 |]. split.
    + intros chunk b offset Havoid.
      assert (H4 := analog_avoid_float_field chunk b offset controller 4 ltac:(lia) ltac:(lia) Havoid).
      assert (H8 := analog_avoid_float_field chunk b offset controller 8 ltac:(lia) ltac:(lia) Havoid).
      assert (H12 := analog_avoid_float_field chunk b offset controller 12 ltac:(lia) ltac:(lia) Havoid).
      rewrite Hf10 by exact H12. rewrite Hf9 by exact H8. rewrite Hf8 by exact H4.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs7) by exact H12.
      rewrite Hf6 by exact H8. rewrite Hf5 by exact H8.
      rewrite Hf4 by exact H4. rewrite Hf3 by exact H4.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
        (unfold playback_read_avoids in Havoid; destruct Havoid as [H | [H | H]];
          first [left; exact H | right; left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
        (unfold playback_read_avoids in Havoid; destruct Havoid as [H | [H | H]];
          first [left; exact H | right; left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
      reflexivity.
    + intros b offset kind perm Hperm.
      apply Hp10, Hp9, Hp8. eapply Mem.perm_store_1; [exact Hs7 |].
      apply Hp6, Hp5, Hp4, Hp3.
      eapply Mem.perm_store_1; [exact Hs2 |]. eapply Mem.perm_store_1; eassumption.
Qed.

Theorem generated_arbitrary_analog_call_executes :
  forall ge (layout : controller_input_layout ge) before controller sqrt rawx rawy magnitude,
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle (arbitrary_analog_square_sum rawx rawy)] m E0 (Vsingle magnitude) m) ->
    Mem.load Mint16signed before controller 0 = Some (Vint rawx) ->
    Mem.load Mint16signed before controller 2 = Some (Vint rawy) ->
    Mem.valid_access before Mfloat32 controller 4 Writable ->
    Mem.valid_access before Mfloat32 controller 8 Writable ->
    Mem.valid_access before Mfloat32 controller 12 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal P.f_adjust_analog_stick)
        [Vptr controller Ptrofs.zero] E0 after Vundef /\
      Mem.load Mfloat32 after controller 4 = Some (Vsingle (arbitrary_analog_final_axis rawx magnitude)) /\
      Mem.load Mfloat32 after controller 8 = Some (Vsingle (arbitrary_analog_final_axis rawy magnitude)) /\
      Mem.load Mfloat32 after controller 12 = Some (Vsingle (arbitrary_analog_final_magnitude magnitude)) /\
      (forall chunk b offset,
        Mem.valid_block before b ->
        playback_read_avoids chunk b offset controller 4 16 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      (forall b offset kind permission,
        Mem.valid_block before b ->
        Mem.perm before b offset kind permission -> Mem.perm after b offset kind permission) /\
      (forall chunk b offset permission,
        Mem.valid_access before chunk b offset permission ->
        Mem.valid_access after chunk b offset permission).
Proof.
  intros ge layout before controller sqrt rawx rawy magnitude Hsqrt Hfind Hmath
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
  destruct (generated_arbitrary_analog_body_executes ge layout
    (controller_analog_env filler) (controller_analog_temps controller) allocated
    controller sqrt rawx rawy magnitude ltac:(reflexivity)
    ltac:(unfold controller_analog_temps; rewrite PTree.gss; reflexivity)
    Hsqrt Hfind Hmath
    ltac:(eapply Mem.load_alloc_other; eassumption)
    ltac:(eapply Mem.load_alloc_other; eassumption)
    ltac:(eapply Mem.valid_access_alloc_other; eassumption)
    ltac:(eapply Mem.valid_access_alloc_other; eassumption)
    ltac:(eapply Mem.valid_access_alloc_other; eassumption))
    as (called & le' & Hbody & Hx & Hy & Hmag & Hframe & Hperm).
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
      (le1 := controller_analog_temps controller) (le2 := le')
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
      intros chunk b offset permission [Hrange Halign]. split; [|exact Halign].
      intros address Haddress. apply Hpermissions.
      * eapply Mem.valid_access_valid_block.
        eapply Mem.valid_access_implies; [split; [exact Hrange | exact Halign] | constructor].
      * apply Hrange. exact Haddress.
Qed.


Definition demo_arbitrary_analog_call_claim (f : function) : Prop :=
  forall ge (layout : controller_input_layout ge) before controller sqrt rawx rawy magnitude,
    Genv.find_symbol ge P._sqrtf = Some sqrt ->
    Genv.find_funct ge (Vptr sqrt Ptrofs.zero) = Some controller_sqrt_fundef ->
    (forall m, external_call controller_sqrt_external ge
      [Vsingle (arbitrary_analog_square_sum rawx rawy)] m E0 (Vsingle magnitude) m) ->
    Mem.load Mint16signed before controller 0 = Some (Vint rawx) ->
    Mem.load Mint16signed before controller 2 = Some (Vint rawy) ->
    Mem.valid_access before Mfloat32 controller 4 Writable ->
    Mem.valid_access before Mfloat32 controller 8 Writable ->
    Mem.valid_access before Mfloat32 controller 12 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal f)
        [Vptr controller Ptrofs.zero] E0 after Vundef /\
      Mem.load Mfloat32 after controller 4 = Some (Vsingle (arbitrary_analog_final_axis rawx magnitude)) /\
      Mem.load Mfloat32 after controller 8 = Some (Vsingle (arbitrary_analog_final_axis rawy magnitude)) /\
      Mem.load Mfloat32 after controller 12 = Some (Vsingle (arbitrary_analog_final_magnitude magnitude)) /\
      (forall chunk b offset,
        Mem.valid_block before b ->
        playback_read_avoids chunk b offset controller 4 16 ->
        Mem.load chunk after b offset = Mem.load chunk before b offset) /\
      (forall b offset kind permission,
        Mem.valid_block before b ->
        Mem.perm before b offset kind permission -> Mem.perm after b offset kind permission) /\
      (forall chunk b offset permission,
        Mem.valid_access before chunk b offset permission ->
        Mem.valid_access after chunk b offset permission).

Theorem generated_arbitrary_analog_us_jp_same_function :
  P.f_adjust_analog_stick = jp_game_init.f_adjust_analog_stick.
Proof. reflexivity. Qed.

Definition demo_arbitrary_analog_call_claim_us_jp : Prop :=
  demo_arbitrary_analog_call_claim P.f_adjust_analog_stick /\
  demo_arbitrary_analog_call_claim jp_game_init.f_adjust_analog_stick.

Theorem generated_demo_arbitrary_analog_call_us_jp :
  demo_arbitrary_analog_call_claim_us_jp.
Proof. split; exact generated_arbitrary_analog_call_executes. Qed.