From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
 Ctypes Errors Events Floats Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_camera jp_camera.
From Demo.Generated Require Import us_level_update jp_level_update us_ingame_menu jp_ingame_menu.
From Demo.Proofs Require Import DemoStartExecution DemoGameplayBoundary DemoDelayedWarpTerminalExecution
 DemoNormalPostCameraExecution DemoNormalDelayedExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module DZ := us_camera.
Module DM := us_ingame_menu.
Module DT := us_level_update.

Definition dialog_trigger_two_temps : temp_env :=
 PTree.set DZ._trigger (Vint (Int.repr 2))
   (create_undef_temps (fn_temps DZ.f_trigger_cutscene_dialog)).

Lemma generated_dialog_trigger_two_us_jp_identical :
 DZ.f_trigger_cutscene_dialog = jp_camera.f_trigger_cutscene_dialog.
Proof. reflexivity. Qed.

(** The exact camera callee used by the zoom reset branch. Its unused local
    still causes a real global pointer-cell load in the generated function. *)
Theorem generated_dialog_trigger_two_call_executes_us_jp :
 forall (ge:Clight.genv) (us:bool) before camera_global camera_value,
 Genv.find_symbol ge DZ._gCamera = Some camera_global ->
 Mem.load Mptr before camera_global 0 = Some camera_value ->
 eval_funcall function_entry2 ge before
   (Internal (if us then DZ.f_trigger_cutscene_dialog else jp_camera.f_trigger_cutscene_dialog))
   [Vint (Int.repr 2)] E0 before Vzero.
Proof.
 intros ge us before camera_global camera_value Hsymbol Hcamera.
 assert (Hcall : eval_funcall function_entry2 ge before
   (Internal DZ.f_trigger_cutscene_dialog) [Vint (Int.repr 2)] E0 before Vzero).
 { eapply eval_funcall_internal with (e:=empty_env) (le1:=dialog_trigger_two_temps)
     (m1:=before) (m2:=before) (out:=Out_return (Some (Vzero,tint))).
   - constructor.
     + constructor.
     + constructor; [cbn;tauto|constructor].
     + vm_compute; intuition congruence.
     + constructor.
     + reflexivity.
   - cbn [DZ.f_trigger_cutscene_dialog fn_body]. unfold dialog_trigger_two_temps.
     game_control_stmt.
   - split; [discriminate|reflexivity].
   - reflexivity. }
 destruct us; exact Hcall.
Qed.

Record dialog_any_resources (ge : Clight.genv) (before : mem) : Type := {
 any_timer : block; any_update : block; any_scale : block; any_angle : block;
 any_menu : block; any_dialog : block; any_page : block; any_choice : block;
 any_next : block; any_response : block; any_type : block;
 any_transition_function : block; any_type_value : int;
 any_timer_symbol : Genv.find_symbol ge DT._sTransitionTimer = Some any_timer;
 any_update_symbol : Genv.find_symbol ge DT._sTransitionUpdate = Some any_update;
 any_scale_symbol : Genv.find_symbol ge DM._gDialogBoxScale = Some any_scale;
 any_angle_symbol : Genv.find_symbol ge DM._gDialogBoxAngle = Some any_angle;
 any_menu_symbol : Genv.find_symbol ge DM._gMenuState = Some any_menu;
 any_dialog_symbol : Genv.find_symbol ge DM._gDialogID = Some any_dialog;
 any_page_symbol : Genv.find_symbol ge DM._gDialogPageStartStrIndex = Some any_page;
 any_choice_symbol : Genv.find_symbol ge DM._gDialogWithChoice = Some any_choice;
 any_next_symbol : Genv.find_symbol ge DM._gNextDialogPageStartStrIndex = Some any_next;
 any_response_symbol : Genv.find_symbol ge DM._gDialogResponse = Some any_response;
 any_type_symbol : Genv.find_symbol ge DM._gDialogBoxType = Some any_type;
 any_transition_symbol : Genv.find_symbol ge DM._level_set_transition = Some any_transition_function;
 any_transition_body : Genv.find_funct_ptr ge any_transition_function =
   Some (Internal DT.f_level_set_transition);
 any_type_read : Mem.load Mint8signed before any_type 0 = Some (Vint any_type_value);
 any_type_separate : ~ In any_type [any_timer; any_update];
 any_timer_separate : ~ In any_timer [any_update; any_scale; any_angle;
   any_menu; any_dialog; any_page; any_choice; any_next; any_response];
 any_update_separate : ~ In any_update [any_scale; any_angle;
   any_menu; any_dialog; any_page; any_choice; any_next; any_response];
 any_wtimer : Mem.valid_access before Mint16signed any_timer 0 Writable;
 any_wupdate : Mem.valid_access before Mptr any_update 0 Writable;
 any_wscale : Mem.valid_access before Mfloat32 any_scale 0 Writable;
 any_wangle : Mem.valid_access before Mfloat32 any_angle 0 Writable;
 any_wmenu : Mem.valid_access before Mint8signed any_menu 0 Writable;
 any_wdialog : Mem.valid_access before Mint16signed any_dialog 0 Writable;
 any_wpage : Mem.valid_access before Mint16signed any_page 0 Writable;
 any_wchoice : Mem.valid_access before Mint8signed any_choice 0 Writable;
 any_wnext : Mem.valid_access before Mint16signed any_next 0 Writable;
 any_wresponse : Mem.valid_access before Mint32 any_response 0 Writable;
 any_camera_global : block; any_camera_value : val; any_trigger_function : block;
 any_camera_symbol : Genv.find_symbol ge DZ._gCamera = Some any_camera_global;
 any_camera_read : Mem.load Mptr before any_camera_global 0 = Some any_camera_value;
 any_camera_separate : ~ In any_camera_global [any_timer;any_update];
 any_trigger_symbol : Genv.find_symbol ge DM._trigger_cutscene_dialog = Some any_trigger_function;
 any_trigger_body : Genv.find_funct_ptr ge any_trigger_function =
   Some (Internal DZ.f_trigger_cutscene_dialog)
}.

Definition dialog_any_written ge before (r : dialog_any_resources ge before) : list block :=
 [any_timer ge before r; any_update ge before r; any_scale ge before r;
  any_angle ge before r; any_menu ge before r; any_dialog ge before r;
  any_page ge before r; any_choice ge before r; any_next ge before r;
  any_response ge before r].

Lemma generated_any_dialog_reset_call_us_jp : forall ge before (r:dialog_any_resources ge before),
 exists after,
  eval_funcall function_entry2 ge before (Internal DM.f_reset_dialog_render_state)
    [] E0 after Vundef /\
  eval_funcall function_entry2 ge before (Internal jp_ingame_menu.f_reset_dialog_render_state)
    [] E0 after Vundef /\
  Mem.load Mint16signed after (any_timer ge before r) 0 = Some Vzero /\
  Mem.load Mptr after (any_update ge before r) 0 = Some Vzero /\
  (forall chunk b ofs, ~ In b (dialog_any_written ge before r) ->
    Mem.load chunk after b ofs = Mem.load chunk before b ofs) /\
  (forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b) /\
  (forall b ofs, Mem.weak_valid_pointer before b ofs = true ->
    Mem.weak_valid_pointer after b ofs = true).
Proof.
 intros ge before r. destruct r.
 destruct (generated_set_transition_zero_call ge before any_timer0 any_update0
   any_timer_symbol0 any_update_symbol0 any_wtimer0 any_wupdate0)
   as (m1 & m2 & Hs1 & Hs2 & Htransition).
 assert (Hcamera2 : Mem.load Mptr m2 any_camera_global0 0 = Some any_camera_value0) by terminal_load.
 pose proof (generated_dialog_trigger_two_call_executes_us_jp ge true m2 any_camera_global0
   any_camera_value0 any_camera_symbol0 Hcamera2) as Htrigger_call.
 destruct (Mem.valid_access_store m2 Mfloat32 any_scale0 0
   (Vsingle (Float32.of_bits (Int.repr 1100480512))) ltac:(demo_access)) as [m3 Hs3].
 destruct (Mem.valid_access_store m3 Mfloat32 any_angle0 0
   (Vsingle (Float32.of_bits (Int.repr 1119092736))) ltac:(demo_access)) as [m4 Hs4].
 destruct (Mem.valid_access_store m4 Mint8signed any_menu0 0 Vzero ltac:(demo_access)) as [m5 Hs5].
 destruct (Mem.valid_access_store m5 Mint16signed any_dialog0 0
   (Vint (Int.repr (-1))) ltac:(demo_access)) as [m6 Hs6].
 destruct (Mem.valid_access_store m6 Mint16signed any_page0 0 Vzero ltac:(demo_access)) as [m7 Hs7].
 destruct (Mem.valid_access_store m7 Mint8signed any_choice0 0 Vzero ltac:(demo_access)) as [m8 Hs8].
 destruct (Mem.valid_access_store m8 Mint16signed any_next0 0 Vzero ltac:(demo_access)) as [m9 Hs9].
 destruct (Mem.valid_access_store m9 Mint32 any_response0 0 Vzero ltac:(demo_access)) as [after Hs10].
 assert (Hcall : eval_funcall function_entry2 ge before
     (Internal DM.f_reset_dialog_render_state) [] E0 after Vundef).
 { eapply eval_funcall_internal with (e:=empty_env)
     (le1:=create_undef_temps (fn_temps DM.f_reset_dialog_render_state))
     (m1:=before) (m2:=after) (out:=Out_normal).
   - constructor; [constructor | constructor | unfold list_disjoint; cbn; tauto | constructor | reflexivity].
   - cbn [DM.f_reset_dialog_render_state fn_body].
     eapply exec_Sseq_1 with (t1:=E0) (t2:=E0).
     + eapply exec_Scall with (vf:=Vptr any_transition_function0 Ptrofs.zero)
         (f:=Internal DT.f_level_set_transition) (vargs:=[Vzero;Vzero]) (vres:=Vundef);
         [reflexivity | terminal_expr | repeat econstructor; reflexivity |
          exact any_transition_body0 | reflexivity | exact Htransition].
     + eapply exec_Sseq_1 with (t1:=E0) (t2:=E0).
       * eapply exec_Sseq_1 with (t1:=E0) (t2:=E0).
         -- eapply exec_Sset. terminal_expr.
         -- destruct (Int.eq any_type_value0 Int.one) eqn:Hzoom.
            ++ eapply exec_Sifthenelse with (v1:=Vint Int.one) (b:=true).
               ** eapply eval_Ebinop; [terminal_expr|constructor|].
                  change (Some (Val.of_bool (Int.eq any_type_value0 Int.one))=Some(Vint Int.one)).
                  rewrite Hzoom. reflexivity.
               ** reflexivity.
               ** eapply exec_Scall with(vf:=Vptr any_trigger_function0 Ptrofs.zero)
                    (f:=Internal DZ.f_trigger_cutscene_dialog)(vargs:=[Vint(Int.repr 2)])(vres:=Vzero);
                    [reflexivity|terminal_expr|repeat econstructor;reflexivity|
                     exact any_trigger_body0|reflexivity|exact Htrigger_call].
            ++ eapply exec_Sifthenelse with (v1:=Vzero) (b:=false).
               ** eapply eval_Ebinop; [terminal_expr|constructor|].
                  change (Some (Val.of_bool (Int.eq any_type_value0 Int.one))=Some Vzero).
                  rewrite Hzoom. reflexivity.
               ** reflexivity.
               ** constructor.
       * terminal_stmt.
   - reflexivity.
   - reflexivity. }
 exists after. split; [exact Hcall |]. split; [exact Hcall |].
 split; [cbn; terminal_load |]. split; [cbn; terminal_load |]. split.
 - intros chunk b ofs Houtside. cbn [dialog_any_written] in Houtside.
   repeat match goal with H : Mem.store _ _ _ _ _ = Some ?m |- Mem.load _ ?m _ _ = _ =>
     rewrite (Mem.load_store_other _ _ _ _ _ _ H) by (left; terminal_separate)
   end. reflexivity.
 - split.
   + intros chunk b ofs permission Haccess. demo_access.
   + split.
     * intros b Hvalid. repeat match goal with H : Mem.store _ _ _ _ _ = Some ?m |-
         Mem.valid_block ?m _ => eapply Mem.store_valid_block_1; [exact H |]
       end. exact Hvalid.
     * intros b ofs Hvalid. apply Mem.weak_valid_pointer_spec in Hvalid.
       apply Mem.weak_valid_pointer_spec.
       destruct Hvalid as [Hvalid|Hvalid]; [left|right];
       apply Mem.valid_pointer_nonempty_perm in Hvalid;
       apply Mem.valid_pointer_nonempty_perm;
       repeat match goal with H : Mem.store _ _ _ _ _ = Some ?m |-
         Mem.perm ?m _ _ _ _ => eapply Mem.perm_store_1; [exact H |]
       end; exact Hvalid.
Qed.

Definition dialog_any_resources_with_memory ge before after
 (r:dialog_any_resources ge before)
 (Haccess:forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission)
 (Htype:Mem.load Mint8signed after (any_type ge before r) 0 =
   Some (Vint (any_type_value ge before r)))
 (Hcamera:Mem.load Mptr after (any_camera_global ge before r) 0 =
   Some (any_camera_value ge before r)) : dialog_any_resources ge after.
Proof.
 destruct r.
 refine {| any_timer:=any_timer0; any_update:=any_update0;
   any_scale:=any_scale0; any_angle:=any_angle0; any_menu:=any_menu0;
   any_dialog:=any_dialog0; any_page:=any_page0; any_choice:=any_choice0;
   any_next:=any_next0; any_response:=any_response0; any_type:=any_type0;
   any_transition_function:=any_transition_function0; any_type_value:=any_type_value0;
   any_camera_global:=any_camera_global0;any_camera_value:=any_camera_value0;
   any_trigger_function:=any_trigger_function0 |};
   first [assumption | apply Haccess; assumption].
Defined.


Definition terminal_any_written ge before (r:dialog_any_resources ge before)
 (delayed_timer mode counter special:block) : list block :=
 delayed_timer :: dialog_any_written ge before r ++ [mode;counter;special].

Definition demo_terminal_any_dialog_execution_claim : Prop :=
 forall (ge:Clight.genv) (us:bool) before (r:dialog_any_resources ge before)
   operation delayed_timer debug current stream record mode counter special any_function warp_function,
 Genv.find_symbol ge DT._sDelayedWarpOp = Some operation ->
 Genv.find_symbol ge DT._sDelayedWarpTimer = Some delayed_timer ->
 Genv.find_symbol ge DT._gDebugLevelSelect = Some debug ->
 Genv.find_symbol ge DT._gCurrDemoInput = Some current ->
 Genv.find_symbol ge DT._sCurrPlayMode = Some mode ->
 Genv.find_symbol ge DT._D_80339ECA = Some counter ->
 Genv.find_symbol ge DT._D_80339EE0 = Some special ->
 Genv.find_symbol ge DT._reset_dialog_render_state = Some any_function ->
 Genv.find_funct_ptr ge any_function = Some (Internal DM.f_reset_dialog_render_state) ->
 Genv.find_symbol ge DT._warp_special = Some warp_function ->
 Genv.find_funct_ptr ge warp_function = Some (Internal DT.f_warp_special) ->
 Mem.load Mint16signed before operation 0 = Some (Vint (Int.repr 22)) ->
 Mem.load Mint16signed before delayed_timer 0 = Some (Vint Int.one) ->
 Mem.load Mint8signed before debug 0 = Some Vzero ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.weak_valid_pointer before stream (Ptrofs.unsigned record) = true ->
 Mem.valid_access before Mint16signed delayed_timer 0 Writable ->
 Mem.valid_access before Mint16signed mode 0 Writable ->
 Mem.valid_access before Mint16unsigned counter 0 Writable ->
 Mem.valid_access before Mint16signed special 0 Writable ->
 mode <> counter -> mode <> special -> counter <> special ->
 any_type ge before r <> delayed_timer ->
 any_camera_global ge before r <> delayed_timer ->
 (forall b, In b [operation;debug;current] ->
   ~ In b (terminal_any_written ge before r delayed_timer mode counter special)) ->
 (forall b, In b [delayed_timer; any_timer ge before r; any_update ge before r] ->
   ~ In b [mode;counter;special]) ->
 ~ In delayed_timer (dialog_any_written ge before r) ->
 exists after,
  eval_funcall function_entry2 ge before
   (Internal (if us then DT.f_initiate_delayed_warp else jp_level_update.f_initiate_delayed_warp))
   [] E0 after Vundef /\
  Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
  Mem.load Mint16signed after delayed_timer 0 = Some Vzero /\
  Mem.load Mint16signed after mode 0 = Some (Vint (Int.repr 4)) /\
  Mem.load Mint16signed after special 0 = Some (Vint (Int.repr (-2))) /\
  Mem.load Mint16signed after (any_timer ge before r) 0 = Some Vzero /\
  Mem.load Mptr after (any_update ge before r) 0 = Some Vzero /\
  (forall chunk b ofs,
   ~ In b (terminal_any_written ge before r delayed_timer mode counter special) ->
   Mem.load chunk after b ofs = Mem.load chunk before b ofs) /\
  (forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b).

Theorem generated_terminal_any_dialog_warp_executes_us_jp : demo_terminal_any_dialog_execution_claim.
Proof.
 intros ge us before r operation delayed_timer debug current stream record mode counter special
   any_function warp_function Hop_symbol Htimer_symbol Hdebug_symbol Hcurrent_symbol
   Hmode_symbol Hcounter_symbol Hspecial_symbol Hreset_symbol Hreset_body Hwarp_symbol Hwarp_body
   Hop Htimer Hdebug Hcurrent Hstream Hwtimer Hwmode Hwcounter Hwspecial Hmc Hms Hcs
   Htype_separate Hcamera_separate Hread_separate Hwarp_separate Htimer_reset_separate.
 destruct (Mem.valid_access_store before Mint16signed delayed_timer 0 Vzero Hwtimer)
   as [m1 Hs0].
 assert (Haccess1 : forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
   Mem.valid_access m1 chunk b ofs permission) by (intros; demo_access).
 assert (Htype1 : Mem.load Mint8signed m1 (any_type ge before r) 0 =
   Some (Vint (any_type_value ge before r))).
 { rewrite (Mem.load_store_other _ _ _ _ _ _ Hs0) by (left; exact Htype_separate).
   exact (any_type_read ge before r). }
 assert (Hcamera1 : Mem.load Mptr m1 (any_camera_global ge before r) 0 =
   Some (any_camera_value ge before r)).
 { rewrite (Mem.load_store_other _ _ _ _ _ _ Hs0) by(left;exact Hcamera_separate).
   exact (any_camera_read ge before r). }
 set (r1 := dialog_any_resources_with_memory ge before m1 r Haccess1 Htype1 Hcamera1).
 assert (Hwritten1 : dialog_any_written ge m1 r1 = dialog_any_written ge before r)
   by (unfold r1; destruct r; reflexivity).
 assert (Hrtimer1 : any_timer ge m1 r1 = any_timer ge before r)
   by (unfold r1; destruct r; reflexivity).
 assert (Hrupdate1 : any_update ge m1 r1 = any_update ge before r)
   by (unfold r1; destruct r; reflexivity).
 destruct (generated_any_dialog_reset_call_us_jp ge m1 r1)
   as (reset & Hreset_call & Hreset_call_jp & Hreset_timer & Hreset_update & Hreset_frame &
     Hreset_access & Hreset_valid & Hreset_pointer).
 rewrite Hwritten1 in Hreset_frame. rewrite Hrtimer1 in Hreset_timer.
 rewrite Hrupdate1 in Hreset_update.
 assert (Hread_frame : forall chunk b ofs, In b [operation;debug;current] ->
   Mem.load chunk reset b ofs = Mem.load chunk before b ofs).
 { intros chunk b ofs Hread. rewrite Hreset_frame.
   - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs0) by
       (left; intro Heq; apply (Hread_separate b Hread);
        unfold terminal_any_written; left; congruence).
     reflexivity.
   - intro Hin. apply (Hread_separate b Hread). unfold terminal_any_written.
     right. apply in_or_app; left; exact Hin. }
 assert (Hop_reset : Mem.load Mint16signed reset operation 0 = Some (Vint (Int.repr 22)))
   by (rewrite Hread_frame by (cbn; tauto); exact Hop).
 assert (Hdebug_reset : Mem.load Mint8signed reset debug 0 = Some Vzero)
   by (rewrite Hread_frame by (cbn; tauto); exact Hdebug).
 assert (Hcurrent_reset : Mem.load Mptr reset current 0 = Some (Vptr stream record))
   by (rewrite Hread_frame by (cbn; tauto); exact Hcurrent).
 assert (Hstream_reset : Mem.weak_valid_pointer reset stream (Ptrofs.unsigned record) = true).
 { apply Hreset_pointer. apply Mem.weak_valid_pointer_spec in Hstream.
   apply Mem.weak_valid_pointer_spec. destruct Hstream as [Hp|Hp]; [left|right];
   apply Mem.valid_pointer_nonempty_perm; apply Mem.valid_pointer_nonempty_perm in Hp;
   eapply Mem.perm_store_1; eassumption. }
 destruct (generated_warp_special_call_executes ge reset mode counter special
   (Int.neg (Int.repr 2)) Hmode_symbol Hcounter_symbol Hspecial_symbol Hmc Hms Hcs
   ltac:(apply Hreset_access; apply Haccess1; exact Hwmode)
   ltac:(apply Hreset_access; apply Haccess1; exact Hwcounter)
   ltac:(apply Hreset_access; apply Haccess1; exact Hwspecial))
   as (w1 & w2 & after & Hs11 & Hs12 & Hs13 & Hwarp_call & Hmode_after & Hspecial_after & Hwarp_frame).
 assert (Hcall : eval_funcall function_entry2 ge before
   (Internal DT.f_initiate_delayed_warp) [] E0 after Vundef).
 { eapply eval_funcall_internal with (e:=empty_env)
     (le1:=create_undef_temps (fn_temps DT.f_initiate_delayed_warp))
     (m1:=before) (m2:=after) (out:=Out_normal).
   - constructor; [constructor | constructor | unfold list_disjoint; cbn; tauto | constructor | reflexivity].
   - cbn [DT.f_initiate_delayed_warp fn_body]. terminal_stmt.
   - reflexivity.
   - reflexivity. }
 exists after. split; [destruct us; exact Hcall |].
 split.
 - rewrite Hwarp_frame by (intro Heq; apply (Hread_separate operation ltac:(cbn; tauto));
     unfold terminal_any_written; right; apply in_or_app; right; cbn; intuition congruence).
   exact Hop_reset.
 - split.
   + rewrite Hwarp_frame by (intro Heq;
       apply (Hwarp_separate delayed_timer ltac:(cbn; tauto)); cbn; intuition congruence).
     rewrite Hreset_frame by exact Htimer_reset_separate.
     rewrite (Mem.load_store_same _ _ _ _ _ _ Hs0). reflexivity.
   + split; [exact Hmode_after |]. split; [exact Hspecial_after |].
     split.
     * rewrite Hwarp_frame by (intro Heq;
         apply (Hwarp_separate (any_timer ge before r) ltac:(cbn; tauto));
         cbn; intuition congruence). exact Hreset_timer.
     * split.
       -- rewrite Hwarp_frame by (intro Heq;
            apply (Hwarp_separate (any_update ge before r) ltac:(cbn; tauto));
            cbn; intuition congruence). exact Hreset_update.
       -- split.
          ++ intros chunk b ofs Houtside. unfold terminal_any_written in Houtside.
             rewrite Hwarp_frame by (intro; subst; apply Houtside; right;
               apply in_or_app; right; cbn; auto).
             rewrite Hreset_frame by (intro Hin; apply Houtside; right;
               apply in_or_app; left; exact Hin).
             rewrite (Mem.load_store_other _ _ _ _ _ _ Hs0) by
               (left; intro; subst; apply Houtside; left; reflexivity). reflexivity.
          ++ split.
             ** intros chunk b ofs permission Haccess. repeat match goal with
                H : Mem.store _ _ _ _ _ = Some ?m |- Mem.valid_access ?m _ _ _ _ =>
                eapply Mem.store_valid_access_1; [exact H |]
                end. apply Hreset_access. apply Haccess1. exact Haccess.
             ** intros b Hvalid. repeat match goal with
                H : Mem.store _ _ _ _ _ = Some ?m |- Mem.valid_block ?m _ =>
                eapply Mem.store_valid_block_1; [exact H |]
                end. apply Hreset_valid. eapply Mem.store_valid_block_1; eassumption.
Qed.

Definition demo_normal_any_dialog_terminal_suffix_claim : Prop :=
 forall (ge:Clight.genv) (us:bool) le before (r:dialog_any_resources ge before)
   operation delayed_timer debug current stream record mode counter special any_function warp_function delayed_function,
 Genv.find_symbol ge DT._sDelayedWarpOp = Some operation ->
 Genv.find_symbol ge DT._sDelayedWarpTimer = Some delayed_timer ->
 Genv.find_symbol ge DT._gDebugLevelSelect = Some debug ->
 Genv.find_symbol ge DT._gCurrDemoInput = Some current ->
 Genv.find_symbol ge DT._sCurrPlayMode = Some mode ->
 Genv.find_symbol ge DT._D_80339ECA = Some counter ->
 Genv.find_symbol ge DT._D_80339EE0 = Some special ->
 Genv.find_symbol ge DT._reset_dialog_render_state = Some any_function ->
 Genv.find_funct_ptr ge any_function = Some (Internal DM.f_reset_dialog_render_state) ->
 Genv.find_symbol ge DT._warp_special = Some warp_function ->
 Genv.find_funct_ptr ge warp_function = Some (Internal DT.f_warp_special) ->
 Mem.load Mint16signed before operation 0 = Some (Vint (Int.repr 22)) ->
 Mem.load Mint16signed before delayed_timer 0 = Some (Vint Int.one) ->
 Mem.load Mint8signed before debug 0 = Some Vzero ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.weak_valid_pointer before stream (Ptrofs.unsigned record) = true ->
 Mem.valid_access before Mint16signed delayed_timer 0 Writable ->
 Mem.valid_access before Mint16signed mode 0 Writable ->
 Mem.valid_access before Mint16unsigned counter 0 Writable ->
 Mem.valid_access before Mint16signed special 0 Writable ->
 mode <> counter -> mode <> special -> counter <> special ->
 any_type ge before r <> delayed_timer ->
 any_camera_global ge before r <> delayed_timer ->
 (forall b, In b [operation;debug;current] ->
   ~ In b (terminal_any_written ge before r delayed_timer mode counter special)) ->
 (forall b, In b [delayed_timer; any_timer ge before r; any_update ge before r] ->
   ~ In b [mode;counter;special]) ->
 ~ In delayed_timer (dialog_any_written ge before r) ->
 Genv.find_symbol ge DT._initiate_delayed_warp = Some delayed_function ->
 Genv.find_funct_ptr ge delayed_function = Some (Internal DT.f_initiate_delayed_warp) ->
 exists after,
  exec_stmt function_entry2 ge empty_env le before
   (normal_afterpainting_suffix (fn_body
     (if us then DT.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
   E0 (PTree.set DT._t'6 (Vint (Int.repr 4)) le) after
   (Out_return (Some (Vzero,tint))) /\
  Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
  Mem.load Mint16signed after delayed_timer 0 = Some Vzero /\
  Mem.load Mint16signed after mode 0 = Some (Vint (Int.repr 4)) /\
  Mem.load Mint16signed after special 0 = Some (Vint (Int.repr (-2))) /\
  Mem.load Mint16signed after (any_timer ge before r) 0 = Some Vzero /\
  Mem.load Mptr after (any_update ge before r) 0 = Some Vzero /\
  (forall chunk b ofs,
   ~ In b (terminal_any_written ge before r delayed_timer mode counter special) ->
   Mem.load chunk after b ofs = Mem.load chunk before b ofs) /\
  (forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b).


Theorem generated_normal_any_dialog_terminal_suffix_executes_us_jp :
 demo_normal_any_dialog_terminal_suffix_claim.
Proof.
 intros ge us le before r operation delayed_timer debug current stream record mode counter special
   any_function warp_function delayed_function Hop_symbol Htimer_symbol Hdebug_symbol Hcurrent_symbol
   Hmode_symbol Hcounter_symbol Hspecial_symbol Hreset_symbol Hreset_body Hwarp_symbol Hwarp_body
   Hop Htimer Hdebug Hcurrent Hstream Hwtimer Hwmode Hwcounter Hwspecial Hmc Hms Hcs
   Htype_separate Hcamera_separate Hread_separate Hwarp_separate Htimer_reset_separate Hdelayed_symbol Hdelayed_body.
 destruct (generated_terminal_any_dialog_warp_executes_us_jp ge true before r
   operation delayed_timer debug current stream record mode counter special any_function warp_function
   Hop_symbol Htimer_symbol Hdebug_symbol Hcurrent_symbol Hmode_symbol Hcounter_symbol Hspecial_symbol
   Hreset_symbol Hreset_body Hwarp_symbol Hwarp_body Hop Htimer Hdebug Hcurrent Hstream
   Hwtimer Hwmode Hwcounter Hwspecial Hmc Hms Hcs Htype_separate Hcamera_separate Hread_separate Hwarp_separate
   Htimer_reset_separate)
   as (after & Hcall & Hop_after & Htimer_after & Hmode_after & Hspecial_after &
     Htransition_after & Hupdate_after & Hframe & Haccess & Hvalid).
 exists after. split.
 - assert (Hselected : normal_afterpainting_suffix (fn_body
       (if us then DT.f_play_mode_normal else jp_level_update.f_play_mode_normal)) =
       normal_afterpainting_suffix (fn_body DT.f_play_mode_normal)) by (destruct us; reflexivity).
   rewrite Hselected.
   change (exec_stmt function_entry2 ge empty_env le before
     (Ssequence
       (Scall None (Evar DT._initiate_delayed_warp (Tfunction [] tvoid cc_default)) [])
       (normal_decision_suffix (fn_body DT.f_play_mode_normal)))
     E0 (PTree.set DT._t'6 (Vint (Int.repr 4)) le) after
     (Out_return (Some (Vzero,tint)))).
   eapply exec_Sseq_1 with (t1:=E0) (t2:=E0) (le1:=le) (m1:=after).
   + eapply exec_Scall with (vargs:=[]) (vres:=Vundef);
       [reflexivity|demo_expr|constructor|cbn; exact Hdelayed_body|reflexivity|exact Hcall].
   + exact (generated_normal_exit_decision_executes_us_jp ge true le after mode Hmode_symbol Hmode_after).
 - repeat first [assumption | split].
Qed.

Definition demo_dialog_zoom_terminal_execution_claim : Prop :=
 demo_terminal_any_dialog_execution_claim /\ demo_normal_any_dialog_terminal_suffix_claim.

Theorem generated_dialog_zoom_terminal_execution_us_jp : demo_dialog_zoom_terminal_execution_claim.
Proof. split; [exact generated_terminal_any_dialog_warp_executes_us_jp |
 exact generated_normal_any_dialog_terminal_suffix_executes_us_jp]. Qed.
