From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
 Ctypes Errors Events Floats Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoPlaybackExecution DemoControllerInputExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module CC := us_game_init.

Definition controller_data_decision (body : statement) : statement :=
 match body with
 | Ssequence _ (Ssequence _
   (Ssequence (Ssequence _ (Sloop (Ssequence _ (Ssequence _ decision)) _)) _)) => decision
 | _ => Sskip
 end.

Definition controller_player3_suffix (body : statement) : statement :=
 match body with Ssequence _ (Ssequence _ (Ssequence _ copy)) => copy | _ => Sskip end.

Lemma generated_controller_copy_selectors :
 controller_data_decision (fn_body CC.f_read_controller_inputs) <>
   Sskip /\
 controller_player3_suffix (fn_body CC.f_read_controller_inputs) <> Sskip /\
 controller_data_decision (fn_body CC.f_read_controller_inputs) =
   controller_data_decision (fn_body jp_game_init.f_read_controller_inputs) /\
 controller_player3_suffix (fn_body CC.f_read_controller_inputs) =
   controller_player3_suffix (fn_body jp_game_init.f_read_controller_inputs).
Proof. repeat split; first [discriminate | reflexivity]. Qed.

Definition controller_outside_bytes (controllers : block) (first past : Z)
    (b : block) (byte : Z) : Prop :=
 b <> controllers \/ byte < first \/ past <= byte.

Lemma controller_store_unchanged : forall before after chunk controllers offset value first past,
 Mem.store chunk before controllers offset value = Some after ->
 first <= offset -> offset + size_chunk chunk <= past ->
 Mem.unchanged_on (controller_outside_bytes controllers first past) before after.
Proof.
 intros before after chunk controllers offset value first past Hstore Hfirst Hpast.
 eapply Mem.store_unchanged_on; [exact Hstore |].
 unfold controller_outside_bytes. intros byte Hbyte [Hdifferent | [Hbefore | Hafter]];
   first [contradiction | lia].
Qed.

Lemma controller_load_preserved : forall before after controllers first past chunk b offset value,
 Mem.unchanged_on (controller_outside_bytes controllers first past) before after ->
 playback_read_avoids chunk b offset controllers first past ->
 Mem.load chunk before b offset = Some value -> Mem.load chunk after b offset = Some value.
Proof.
 intros before after controllers first past chunk b offset value Hframe Havoids Hload.
 eapply Mem.load_unchanged_on; [exact Hframe | | exact Hload].
 unfold controller_outside_bytes. unfold playback_read_avoids in Havoids.
 intros byte Hbyte; destruct Havoids as [Hdifferent | [Hbefore | Hafter]];
   first [left; exact Hdifferent | right; left; lia | right; right; lia].
Qed.

Lemma controller_loadbytes_preserved : forall before after controllers first past b offset count bytes,
 Mem.unchanged_on (controller_outside_bytes controllers first past) before after ->
 (b <> controllers \/ offset + count <= first \/ past <= offset) ->
 Mem.loadbytes before b offset count = Some bytes ->
 Mem.loadbytes after b offset count = Some bytes.
Proof.
 intros before after controllers first past b offset count bytes Hframe Havoids Hload.
 eapply Mem.loadbytes_unchanged_on; [exact Hframe | | exact Hload].
 unfold controller_outside_bytes. intros byte Hbyte.
 destruct Havoids as [Hdifferent | [Hbefore | Hafter]];
   first [left; exact Hdifferent | right; left; lia | right; right; lia].
Qed.

Ltac controller_copy_load :=
 lazymatch goal with |- Mem.load ?chunk ?memory ?b ?offset = ?value =>
   let actual := eval vm_compute in offset in change (Mem.load chunk memory b actual = value)
 end;
 first [eassumption |
  match goal with H : Mem.store _ _ _ _ _ = Some ?memory |-
      Mem.load _ ?memory _ _ = _ =>
   first
   [rewrite (Mem.load_store_same _ _ _ _ _ _ H);
    cbn -[Int.sign_ext Int.zero_ext Float32.of_int controller_float_zero];
    repeat rewrite Int.sign_ext_idem by lia;
    repeat rewrite Int.zero_ext_idem by lia;
    first [reflexivity | congruence]
   |rewrite (Mem.load_store_other _ _ _ _ _ _ H) by
      (first [left; congruence | right; left; vm_compute; discriminate |
        right; right; vm_compute; discriminate]);
    controller_copy_load]
  end | match goal with |- ?g => idtac "CONTROLLER COPY LOAD FAILED" g; fail 100 end].

Ltac controller_copy_reduce :=
 first [analog_normalize | vm_compute; reflexivity |
   match goal with |- ?g => idtac "CONTROLLER COPY REDUCTION FAILED" g; fail 100 end].

Ltac controller_copy_expr :=
 lazymatch goal with
 | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
 | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
   eapply eval_Etempvar; repeat rewrite PTree.gsspec;
   cbn -[Float32.of_int controller_float_zero]; first [reflexivity | eassumption |
     match goal with |- ?g => idtac "COPY TEMP FAILED" g; fail 100 end]
 | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
   eapply eval_Ebinop; [controller_copy_expr | controller_copy_expr | controller_copy_reduce]
 | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
   eapply eval_Ecast; [controller_copy_expr | controller_copy_reduce]
 | |- eval_expr _ _ _ _ _ _ => eapply eval_Elvalue;
   [controller_copy_lvalue |
    first [eapply deref_loc_value; [reflexivity | cbn -[Float32.of_int]; controller_copy_load] |
      eapply deref_loc_reference; reflexivity |
      eapply deref_loc_copy; reflexivity]]
 end
with controller_copy_lvalue :=
 lazymatch goal with
 | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
   eapply eval_Evar_global; [reflexivity | eassumption]
 | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; controller_copy_expr
 | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
   eapply eval_Efield_struct; [controller_copy_expr | reflexivity |
     first [eassumption | match goal with |- ?g => idtac "COPY COMPOSITE FAILED" g; fail 100 end] |
     first [eassumption | match goal with |- ?g => idtac "COPY OFFSET FAILED" g; fail 100 end]]
 end.

Ltac controller_copy_stmt :=
 lazymatch goal with
 | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
   eapply exec_Sseq_1 with (t1:=E0) (t2:=E0); [controller_copy_stmt | controller_copy_stmt]
 | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; controller_copy_expr
 | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
   eapply exec_Sassign;
   [controller_copy_lvalue | controller_copy_expr | controller_copy_reduce |
    eapply assign_loc_value; [reflexivity |
     cbn -[Float32.of_int controller_float_zero];
     lazymatch goal with |- Mem.store ?chunk ?memory ?b ?offset ?value = ?out =>
       let actual := eval vm_compute in offset in
       change (Mem.store chunk memory b actual value = out)
     end; eassumption]]
 | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
   first
   [eapply exec_Sifthenelse with (v1:=Vzero) (b:=false);
     [controller_copy_expr | reflexivity | controller_copy_stmt]
   |eapply exec_Sifthenelse with (v1:=Vint Int.one) (b:=true);
     [controller_copy_expr | reflexivity | controller_copy_stmt]]
 | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => apply exec_Sskip
 end.

Ltac controller_copy_frame :=
 first [apply Mem.unchanged_on_refl |
  lazymatch goal with
  | |- Mem.unchanged_on _ ?before ?after =>
    match goal with H : Mem.store _ ?middle _ _ _ = Some after |- _ =>
      eapply Mem.unchanged_on_trans with (m2:=middle);
      [controller_copy_frame |
       eapply controller_store_unchanged;
       [exact H | vm_compute; discriminate | vm_compute; discriminate]]
    end
  end].

Definition demo_disconnected_second_controller_claim : Prop :=
 forall ge (layout : controller_input_layout ge) (us : bool) le before controllers,
 le ! CC._controller = Some (Vptr controllers (Ptrofs.repr 28)) ->
 Mem.load Mptr before controllers 52 = Some Vzero ->
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
     (if us then CC.f_read_controller_inputs else jp_game_init.f_read_controller_inputs)))
   E0 le' after Out_normal /\
  le' ! CC._controller = Some (Vptr controllers (Ptrofs.repr 28)) /\
  le' ! CC._i = le ! CC._i /\
  Mem.unchanged_on (controller_outside_bytes controllers 28 48) before after /\
  (forall chunk b offset permission, Mem.valid_access before chunk b offset permission ->
    Mem.valid_access after chunk b offset permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b).

Theorem generated_disconnected_second_controller_executes :
 demo_disconnected_second_controller_claim.
Proof.
 intros ge layout us le before controllers Hcontroller Hdata Hwx Hwy Hwpressed Hwdown Hwsx Hwsy Hwsm.
 destruct layout as [layout Hraw_x Hraw_y Hstick_x Hstick_y Hstick_mag Hdown Hpressed].
 destruct layout as [controller_co pad_co record_co Hcontroller_co Hpad_co Hrecord_co
   Hcontroller_size Hdata_offset Hbutton Hx Hy Htimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 cbn in Hraw_x, Hraw_y, Hstick_x, Hstick_y, Hstick_mag, Hdown, Hpressed.
 destruct (Mem.valid_access_store before Mint16signed controllers 28 Vzero Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint16signed controllers 30 Vzero ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint16unsigned controllers 46 Vzero ltac:(demo_access)) as [m3 Hs3].
 destruct (Mem.valid_access_store m3 Mint16unsigned controllers 44 Vzero ltac:(demo_access)) as [m4 Hs4].
 destruct (Mem.valid_access_store m4 Mfloat32 controllers 32
   (Vsingle controller_float_zero) ltac:(demo_access)) as [m5 Hs5].
 destruct (Mem.valid_access_store m5 Mfloat32 controllers 36
   (Vsingle controller_float_zero) ltac:(demo_access)) as [m6 Hs6].
 destruct (Mem.valid_access_store m6 Mfloat32 controllers 40
   (Vsingle controller_float_zero) ltac:(demo_access)) as [after Hs7].
 exists after, (PTree.set CC._t'22 Vzero le). split.
 - assert (Hselected : controller_data_decision (fn_body
     (if us then CC.f_read_controller_inputs else jp_game_init.f_read_controller_inputs)) =
       controller_data_decision (fn_body CC.f_read_controller_inputs)).
   { destruct us; reflexivity. }
   rewrite Hselected.
   cbn [controller_data_decision CC.f_read_controller_inputs fn_body]. controller_copy_stmt.
 - split; [rewrite PTree.gso; [exact Hcontroller | discriminate] |].
   split; [apply PTree.gso; discriminate |]. split; [controller_copy_frame |]. split.
   + intros chunk b offset permission Haccess. demo_access.
   + intros b Hvalid.
     repeat match goal with
     | H : Mem.store _ ?before _ _ _ = Some ?after |-
       Mem.valid_block ?after _ => eapply Mem.store_valid_block_1; [exact H |]
     end. exact Hvalid.
Qed.

Definition demo_player_three_copy_claim : Prop :=
 forall ge (layout : controller_input_layout ge) (us : bool) le before controllers
     player1 player3 rawx rawy stickx sticky magnitude pressed down,
 Genv.find_symbol ge CC._gPlayer1Controller = Some player1 ->
 Genv.find_symbol ge CC._gPlayer3Controller = Some player3 ->
 player1 <> controllers -> player3 <> controllers ->
 Mem.load Mptr before player1 0 = Some (Vptr controllers Ptrofs.zero) ->
 Mem.load Mptr before player3 0 = Some (Vptr controllers (Ptrofs.repr 56)) ->
 Mem.load Mint16signed before controllers 0 = Some (Vint rawx) ->
 Mem.load Mint16signed before controllers 2 = Some (Vint rawy) ->
 Mem.load Mfloat32 before controllers 4 = Some (Vsingle stickx) ->
 Mem.load Mfloat32 before controllers 8 = Some (Vsingle sticky) ->
 Mem.load Mfloat32 before controllers 12 = Some (Vsingle magnitude) ->
 Mem.load Mint16unsigned before controllers 18 = Some (Vint pressed) ->
 Mem.load Mint16unsigned before controllers 16 = Some (Vint down) ->
 Mem.valid_access before Mint16signed controllers 56 Writable ->
 Mem.valid_access before Mint16signed controllers 58 Writable ->
 Mem.valid_access before Mfloat32 controllers 60 Writable ->
 Mem.valid_access before Mfloat32 controllers 64 Writable ->
 Mem.valid_access before Mfloat32 controllers 68 Writable ->
 Mem.valid_access before Mint16unsigned controllers 74 Writable ->
 Mem.valid_access before Mint16unsigned controllers 72 Writable ->
 exists after le',
  exec_stmt function_entry2 ge empty_env le before
   (controller_player3_suffix (fn_body
     (if us then CC.f_read_controller_inputs else jp_game_init.f_read_controller_inputs)))
   E0 le' after Out_normal /\
  le' ! CC._controller = le ! CC._controller /\
  le' ! CC._i = le ! CC._i /\
  Mem.load Mint16signed after controllers 56 = Some (Vint rawx) /\
  Mem.load Mint16signed after controllers 58 = Some (Vint rawy) /\
  Mem.load Mfloat32 after controllers 60 = Some (Vsingle stickx) /\
  Mem.load Mfloat32 after controllers 64 = Some (Vsingle sticky) /\
  Mem.load Mfloat32 after controllers 68 = Some (Vsingle magnitude) /\
  Mem.load Mint16unsigned after controllers 74 = Some (Vint pressed) /\
  Mem.load Mint16unsigned after controllers 72 = Some (Vint down) /\
  Mem.unchanged_on (controller_outside_bytes controllers 56 76) before after /\
  (forall chunk b offset permission, Mem.valid_access before chunk b offset permission ->
    Mem.valid_access after chunk b offset permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b).

Theorem generated_player_three_copy_executes : demo_player_three_copy_claim.
Proof.
 intros ge layout us le before controllers player1 player3 rawx rawy stickx sticky magnitude
   pressed down Hplayer1_symbol Hplayer3_symbol Hplayer1_separate Hplayer3_separate
   Hplayer1 Hplayer3 Hrawx Hrawy Hstickx Hsticky Hmagnitude Hpressed_value Hdown_value
   Hwx Hwy Hwsx Hwsy Hwsm Hwpressed Hwdown.
 destruct layout as [layout Hraw_x Hraw_y Hstick_x Hstick_y Hstick_mag Hdown Hpressed].
 destruct layout as [controller_co pad_co record_co Hcontroller_co Hpad_co Hrecord_co
   Hcontroller_size Hdata_offset Hbutton Hx Hy Htimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 cbn in Hraw_x, Hraw_y, Hstick_x, Hstick_y, Hstick_mag, Hdown, Hpressed.
 pose proof (Mem.load_cast _ _ _ _ _ Hrawx) as Hrawx_normal.
 pose proof (Mem.load_cast _ _ _ _ _ Hrawy) as Hrawy_normal.
 pose proof (Mem.load_cast _ _ _ _ _ Hpressed_value) as Hpressed_normal.
 pose proof (Mem.load_cast _ _ _ _ _ Hdown_value) as Hdown_normal.
 cbn -[Int.sign_ext Int.zero_ext] in Hrawx_normal, Hrawy_normal, Hpressed_normal, Hdown_normal.
 assert (Hrawx_cast : Int.sign_ext 16 rawx = rawx) by congruence.
 assert (Hrawy_cast : Int.sign_ext 16 rawy = rawy) by congruence.
 assert (Hpressed_cast : Int.zero_ext 16 pressed = pressed) by congruence.
 assert (Hdown_cast : Int.zero_ext 16 down = down) by congruence.
 destruct (Mem.valid_access_store before Mint16signed controllers 56 (Vint rawx) Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint16signed controllers 58 (Vint rawy)
   ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mfloat32 controllers 60 (Vsingle stickx)
   ltac:(demo_access)) as [m3 Hs3].
 destruct (Mem.valid_access_store m3 Mfloat32 controllers 64 (Vsingle sticky)
   ltac:(demo_access)) as [m4 Hs4].
 destruct (Mem.valid_access_store m4 Mfloat32 controllers 68 (Vsingle magnitude)
   ltac:(demo_access)) as [m5 Hs5].
 destruct (Mem.valid_access_store m5 Mint16unsigned controllers 74 (Vint pressed)
   ltac:(demo_access)) as [m6 Hs6].
 destruct (Mem.valid_access_store m6 Mint16unsigned controllers 72 (Vint down)
   ltac:(demo_access)) as [after Hs7].
 exists after. eexists. split.
 - assert (Hselected : controller_player3_suffix (fn_body
     (if us then CC.f_read_controller_inputs else jp_game_init.f_read_controller_inputs)) =
       controller_player3_suffix (fn_body CC.f_read_controller_inputs)).
   { destruct us; reflexivity. }
   rewrite Hselected.
   cbn [controller_player3_suffix CC.f_read_controller_inputs fn_body]. controller_copy_stmt.
 - split.
   + repeat rewrite PTree.gso by discriminate. reflexivity.
   + split.
     * repeat rewrite PTree.gso by discriminate. reflexivity.
     * split; [controller_copy_load |].
       split; [controller_copy_load |].
       split; [controller_copy_load |].
       split; [controller_copy_load |].
       split; [controller_copy_load |].
       split; [controller_copy_load |].
       split; [controller_copy_load |].
       split; [controller_copy_frame |]. split.
       -- intros chunk b offset permission Haccess. demo_access.
       -- intros b Hvalid.
          repeat match goal with
          | H : Mem.store _ ?before _ _ _ = Some ?after |-
            Mem.valid_block ?after _ => eapply Mem.store_valid_block_1; [exact H |]
          end. exact Hvalid.
Qed.

Definition demo_controller_copy_execution_claim : Prop :=
 demo_disconnected_second_controller_claim /\ demo_player_three_copy_claim.

Theorem generated_controller_copy_execution_us_jp : demo_controller_copy_execution_claim.
Proof.
 split.
 - exact generated_disconnected_second_controller_executes.
 - exact generated_player_three_copy_executes.
Qed.
