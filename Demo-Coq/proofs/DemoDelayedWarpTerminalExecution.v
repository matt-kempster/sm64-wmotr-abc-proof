From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
 Ctypes Errors Events Floats Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update us_ingame_menu jp_ingame_menu.
From Demo.Proofs Require Import DemoStartExecution DemoGameplayBoundary.
Import ListNotations.
Local Open Scope Z_scope.
Module DT := us_level_update.
Module DM := us_ingame_menu.

Ltac terminal_separate :=
 first [congruence | assumption | intro; subst; cbn in *; tauto].

Ltac terminal_load :=
 lazymatch goal with |- Mem.load ?chunk ?memory ?b ?offset = ?value =>
   let actual := eval vm_compute in offset in change (Mem.load chunk memory b actual = value)
 end;
 first [eassumption |
  match goal with H : Mem.store _ _ _ _ _ = Some ?memory |-
      Mem.load _ ?memory _ _ = _ =>
   first
   [rewrite (Mem.load_store_same _ _ _ _ _ _ H);
    cbn -[Float32.of_bits]; reflexivity
   |rewrite (Mem.load_store_other _ _ _ _ _ _ H) by (left; terminal_separate);
    terminal_load]
  end].

Ltac terminal_expr :=
 lazymatch goal with
 | |- eval_expr _ _ _ _ (Econst_single _ _) _ => constructor
 | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
 | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
   eapply eval_Etempvar; repeat rewrite PTree.gsspec;
   cbn -[Float32.of_bits]; first [reflexivity | eassumption]
 | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
   eapply eval_Ebinop; [terminal_expr | terminal_expr |
    first [match goal with
     | H : Mem.weak_valid_pointer ?m ?b ?ofs = true |- _ = ?out =>
       change (option_map Val.of_bool
         (if Mem.weak_valid_pointer m b ofs then Some true else None) = out);
       rewrite H; reflexivity
     end | demo_reduce; first [reflexivity | congruence]]]
 | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
   eapply eval_Ecast; [terminal_expr | demo_reduce; reflexivity]
 | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
   eapply eval_Eunop; [terminal_expr | reflexivity]
 | |- eval_expr _ _ _ _ _ _ => eapply eval_Elvalue;
   [demo_lvalue |
    first [eapply deref_loc_value; [reflexivity | cbn; terminal_load] |
      eapply deref_loc_reference; reflexivity]]
 end.

Ltac terminal_stmt :=
 lazymatch goal with
 | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
   eapply exec_Sseq_1 with (t1:=E0) (t2:=E0); [terminal_stmt | terminal_stmt]
 | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; terminal_expr
 | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
   eapply exec_Sassign; [demo_lvalue | terminal_expr | demo_reduce; reflexivity |
     eapply assign_loc_value; [reflexivity | cbn; eassumption]]
 | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
   first [eapply exec_Sifthenelse with (v1:=Vzero) (b:=false);
     [terminal_expr | reflexivity | terminal_stmt] |
    eapply exec_Sifthenelse with (v1:=Vint Int.one) (b:=true);
     [terminal_expr | reflexivity | terminal_stmt]]
 | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
   eapply exec_Scall with (vres:=Vundef);
    [reflexivity | terminal_expr | repeat econstructor; try terminal_expr; reflexivity |
     cbn; eassumption | reflexivity | eassumption]
 | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
 end.

Definition transition_zero_temps : temp_env :=
 PTree.set DT._updateFunction Vzero
   (PTree.set DT._length Vzero (PTree.empty _)).

Lemma generated_set_transition_zero_call : forall (ge:Clight.genv) before timer update,
 Genv.find_symbol ge DT._sTransitionTimer = Some timer ->
 Genv.find_symbol ge DT._sTransitionUpdate = Some update ->
 Mem.valid_access before Mint16signed timer 0 Writable ->
 Mem.valid_access before Mptr update 0 Writable ->
 exists m1 after,
  Mem.store Mint16signed before timer 0 Vzero = Some m1 /\
  Mem.store Mptr m1 update 0 Vzero = Some after /\
  eval_funcall function_entry2 ge before (Internal DT.f_level_set_transition)
    [Vzero; Vzero] E0 after Vundef.
Proof.
 intros ge before timer update Htimer Hupdate Hwtimer Hwupdate.
 destruct (Mem.valid_access_store before Mint16signed timer 0 Vzero Hwtimer) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mptr update 0 Vzero ltac:(demo_access)) as [after Hs2].
 exists m1, after. split; [exact Hs1 |]. split; [exact Hs2 |].
 eapply eval_funcall_internal with (e:=empty_env) (le1:=transition_zero_temps)
   (le2:=transition_zero_temps) (m1:=before) (m2:=after) (out:=Out_normal).
 - constructor.
   + constructor.
   + constructor; [cbn; intuition discriminate | constructor; [cbn; tauto | constructor]].
   + unfold list_disjoint; cbn; tauto.
   + constructor.
   + reflexivity.
 - cbn [DT.f_level_set_transition fn_body]. unfold transition_zero_temps. terminal_stmt.
 - reflexivity.
 - reflexivity.
Qed.

Lemma bounded_demo_countdown_arithmetic : forall ticks,
 2 <= ticks <= 20 ->
 Int.sub (Int.repr ticks) Int.one = Int.repr (ticks-1) /\
 Int.sign_ext 16 (Int.repr (ticks-1)) = Int.repr (ticks-1) /\
 Int.eq (Int.repr (ticks-1)) Int.zero = false.
Proof.
 intros ticks Hbounds.
 assert (Hcases : ticks = 2 \/ ticks = 3 \/ ticks = 4 \/ ticks = 5 \/ ticks = 6 \/ ticks = 7 \/ ticks = 8 \/ ticks = 9 \/ ticks = 10 \/ ticks = 11 \/ ticks = 12 \/ ticks = 13 \/ ticks = 14 \/ ticks = 15 \/ ticks = 16 \/ ticks = 17 \/ ticks = 18 \/ ticks = 19 \/ ticks = 20) by lia.
 repeat match goal with H : _ \/ _ |- _ => destruct H end;
   subst ticks; repeat split; reflexivity.
Qed.

Ltac countdown_rewrite :=
 repeat first
 [match goal with H : Int.sub _ _ = _ |- _ => rewrite H end
 |match goal with H : Int.sign_ext _ _ = _ |- _ => rewrite H end
 |match goal with H : Int.eq _ _ = _ |- _ => rewrite H end].

Ltac countdown_reduce :=
 cbn -[Int.sign_ext Int.sub Int.eq Int.repr]; countdown_rewrite;
 reflexivity.

Ltac countdown_expr :=
 lazymatch goal with
 | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
   eapply eval_Ebinop; [countdown_expr | countdown_expr | countdown_reduce]
 | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
   eapply eval_Ecast; [countdown_expr | countdown_reduce]
 | _ => terminal_expr
 end.

Ltac countdown_stmt :=
 lazymatch goal with
 | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
   eapply exec_Sseq_1 with (t1:=E0) (t2:=E0); [countdown_stmt | countdown_stmt]
 | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; countdown_expr
 | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
   eapply exec_Sassign; [demo_lvalue | countdown_expr | countdown_reduce |
     eapply assign_loc_value; [reflexivity |
      cbn -[Int.sign_ext Int.sub Int.eq Int.repr]; countdown_rewrite; eassumption]]
 | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
   first [eapply exec_Sifthenelse with (v1:=Vzero) (b:=false);
     [countdown_expr | reflexivity | countdown_stmt] |
    eapply exec_Sifthenelse with (v1:=Vint Int.one) (b:=true);
     [countdown_expr | reflexivity | countdown_stmt]]
 | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
 end.

Definition demo_bounded_countdown_execution_claim : Prop :=
 forall (ge:Clight.genv) (us:bool) before operation timer ticks,
 Genv.find_symbol ge DT._sDelayedWarpOp = Some operation ->
 Genv.find_symbol ge DT._sDelayedWarpTimer = Some timer ->
 operation <> timer -> 2 <= ticks <= 20 ->
 Mem.load Mint16signed before operation 0 = Some (Vint (Int.repr 22)) ->
 Mem.load Mint16signed before timer 0 = Some (Vint (Int.repr ticks)) ->
 Mem.valid_access before Mint16signed timer 0 Writable ->
 exists after,
  eval_funcall function_entry2 ge before
    (Internal (if us then DT.f_initiate_delayed_warp else jp_level_update.f_initiate_delayed_warp))
    [] E0 after Vundef /\
  Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
  Mem.load Mint16signed after timer 0 = Some (Vint (Int.repr (ticks-1))) /\
  (forall chunk b ofs, b <> timer ->
    Mem.load chunk after b ofs = Mem.load chunk before b ofs) /\
  (forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission).

Theorem generated_bounded_demo_countdown_executes_us_jp : demo_bounded_countdown_execution_claim.
Proof.
 intros ge us before operation timer ticks Hop_symbol Htimer_symbol Hseparate Hbounds Hop Htimer Hw.
 destruct (bounded_demo_countdown_arithmetic ticks Hbounds) as (Hsub & Hsign & Hneq).
 change (Int.sub (Int.repr ticks) (Int.repr 1) = Int.repr (ticks-1)) in Hsub.
 change (Int.eq (Int.repr (ticks-1)) (Int.repr 0) = false) in Hneq.
 assert (H22neq : Int.eq (Int.repr 22) Int.zero = false) by reflexivity.
 destruct (Mem.valid_access_store before Mint16signed timer 0 (Vint (Int.repr (ticks-1))) Hw)
   as [after Hstore].
 assert (Hcall : eval_funcall function_entry2 ge before
   (Internal DT.f_initiate_delayed_warp) [] E0 after Vundef).
 { eapply eval_funcall_internal with (e:=empty_env)
     (le1:=create_undef_temps (fn_temps DT.f_initiate_delayed_warp))
     (m1:=before) (m2:=after) (out:=Out_normal).
   - constructor; [constructor | constructor | unfold list_disjoint; cbn; tauto | constructor | reflexivity].
   - cbn [DT.f_initiate_delayed_warp fn_body]. countdown_stmt.
   - reflexivity.
   - reflexivity. }
 exists after. split; [destruct us; exact Hcall |]. split.
 - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore) by (left; exact Hseparate). exact Hop.
 - split.
   + rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore). cbn -[Int.sign_ext Int.repr].
     rewrite Hsign. reflexivity.
   + split.
     * intros chunk b ofs Havoid. rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore)
         by (left; exact Havoid). reflexivity.
     * intros chunk b ofs permission Haccess. demo_access.
Qed.

Record dialog_reset_resources (ge : Clight.genv) (before : mem) : Type := {
 reset_timer : block; reset_update : block; reset_scale : block; reset_angle : block;
 reset_menu : block; reset_dialog : block; reset_page : block; reset_choice : block;
 reset_next : block; reset_response : block; reset_type : block;
 reset_transition_function : block; reset_type_value : int;
 reset_timer_symbol : Genv.find_symbol ge DT._sTransitionTimer = Some reset_timer;
 reset_update_symbol : Genv.find_symbol ge DT._sTransitionUpdate = Some reset_update;
 reset_scale_symbol : Genv.find_symbol ge DM._gDialogBoxScale = Some reset_scale;
 reset_angle_symbol : Genv.find_symbol ge DM._gDialogBoxAngle = Some reset_angle;
 reset_menu_symbol : Genv.find_symbol ge DM._gMenuState = Some reset_menu;
 reset_dialog_symbol : Genv.find_symbol ge DM._gDialogID = Some reset_dialog;
 reset_page_symbol : Genv.find_symbol ge DM._gDialogPageStartStrIndex = Some reset_page;
 reset_choice_symbol : Genv.find_symbol ge DM._gDialogWithChoice = Some reset_choice;
 reset_next_symbol : Genv.find_symbol ge DM._gNextDialogPageStartStrIndex = Some reset_next;
 reset_response_symbol : Genv.find_symbol ge DM._gDialogResponse = Some reset_response;
 reset_type_symbol : Genv.find_symbol ge DM._gDialogBoxType = Some reset_type;
 reset_transition_symbol : Genv.find_symbol ge DM._level_set_transition = Some reset_transition_function;
 reset_transition_body : Genv.find_funct_ptr ge reset_transition_function =
   Some (Internal DT.f_level_set_transition);
 reset_type_read : Mem.load Mint8signed before reset_type 0 = Some (Vint reset_type_value);
 reset_type_not_zoom : Int.eq reset_type_value Int.one = false;
 reset_type_separate : ~ In reset_type [reset_timer; reset_update];
 reset_timer_separate : ~ In reset_timer [reset_update; reset_scale; reset_angle;
   reset_menu; reset_dialog; reset_page; reset_choice; reset_next; reset_response];
 reset_update_separate : ~ In reset_update [reset_scale; reset_angle;
   reset_menu; reset_dialog; reset_page; reset_choice; reset_next; reset_response];
 reset_wtimer : Mem.valid_access before Mint16signed reset_timer 0 Writable;
 reset_wupdate : Mem.valid_access before Mptr reset_update 0 Writable;
 reset_wscale : Mem.valid_access before Mfloat32 reset_scale 0 Writable;
 reset_wangle : Mem.valid_access before Mfloat32 reset_angle 0 Writable;
 reset_wmenu : Mem.valid_access before Mint8signed reset_menu 0 Writable;
 reset_wdialog : Mem.valid_access before Mint16signed reset_dialog 0 Writable;
 reset_wpage : Mem.valid_access before Mint16signed reset_page 0 Writable;
 reset_wchoice : Mem.valid_access before Mint8signed reset_choice 0 Writable;
 reset_wnext : Mem.valid_access before Mint16signed reset_next 0 Writable;
 reset_wresponse : Mem.valid_access before Mint32 reset_response 0 Writable
}.

Definition dialog_reset_written ge before (r : dialog_reset_resources ge before) : list block :=
 [reset_timer ge before r; reset_update ge before r; reset_scale ge before r;
  reset_angle ge before r; reset_menu ge before r; reset_dialog ge before r;
  reset_page ge before r; reset_choice ge before r; reset_next ge before r;
  reset_response ge before r].

Lemma generated_reset_dialog_call_us_jp : forall ge before (r:dialog_reset_resources ge before),
 exists after,
  eval_funcall function_entry2 ge before (Internal DM.f_reset_dialog_render_state)
    [] E0 after Vundef /\
  eval_funcall function_entry2 ge before (Internal jp_ingame_menu.f_reset_dialog_render_state)
    [] E0 after Vundef /\
  Mem.load Mint16signed after (reset_timer ge before r) 0 = Some Vzero /\
  Mem.load Mptr after (reset_update ge before r) 0 = Some Vzero /\
  (forall chunk b ofs, ~ In b (dialog_reset_written ge before r) ->
    Mem.load chunk after b ofs = Mem.load chunk before b ofs) /\
  (forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b) /\
  (forall b ofs, Mem.weak_valid_pointer before b ofs = true ->
    Mem.weak_valid_pointer after b ofs = true).
Proof.
 intros ge before r. destruct r.
 destruct (generated_set_transition_zero_call ge before reset_timer0 reset_update0
   reset_timer_symbol0 reset_update_symbol0 reset_wtimer0 reset_wupdate0)
   as (m1 & m2 & Hs1 & Hs2 & Htransition).
 destruct (Mem.valid_access_store m2 Mfloat32 reset_scale0 0
   (Vsingle (Float32.of_bits (Int.repr 1100480512))) ltac:(demo_access)) as [m3 Hs3].
 destruct (Mem.valid_access_store m3 Mfloat32 reset_angle0 0
   (Vsingle (Float32.of_bits (Int.repr 1119092736))) ltac:(demo_access)) as [m4 Hs4].
 destruct (Mem.valid_access_store m4 Mint8signed reset_menu0 0 Vzero ltac:(demo_access)) as [m5 Hs5].
 destruct (Mem.valid_access_store m5 Mint16signed reset_dialog0 0
   (Vint (Int.repr (-1))) ltac:(demo_access)) as [m6 Hs6].
 destruct (Mem.valid_access_store m6 Mint16signed reset_page0 0 Vzero ltac:(demo_access)) as [m7 Hs7].
 destruct (Mem.valid_access_store m7 Mint8signed reset_choice0 0 Vzero ltac:(demo_access)) as [m8 Hs8].
 destruct (Mem.valid_access_store m8 Mint16signed reset_next0 0 Vzero ltac:(demo_access)) as [m9 Hs9].
 destruct (Mem.valid_access_store m9 Mint32 reset_response0 0 Vzero ltac:(demo_access)) as [after Hs10].
 assert (Hcall : eval_funcall function_entry2 ge before
     (Internal DM.f_reset_dialog_render_state) [] E0 after Vundef).
 { eapply eval_funcall_internal with (e:=empty_env)
     (le1:=create_undef_temps (fn_temps DM.f_reset_dialog_render_state))
     (m1:=before) (m2:=after) (out:=Out_normal).
   - constructor; [constructor | constructor | unfold list_disjoint; cbn; tauto | constructor | reflexivity].
   - cbn [DM.f_reset_dialog_render_state fn_body].
     eapply exec_Sseq_1 with (t1:=E0) (t2:=E0).
     + eapply exec_Scall with (vf:=Vptr reset_transition_function0 Ptrofs.zero)
         (f:=Internal DT.f_level_set_transition) (vargs:=[Vzero;Vzero]) (vres:=Vundef);
         [reflexivity | terminal_expr | repeat econstructor; reflexivity |
          exact reset_transition_body0 | reflexivity | exact Htransition].
     + eapply exec_Sseq_1 with (t1:=E0) (t2:=E0).
       * eapply exec_Sseq_1 with (t1:=E0) (t2:=E0).
         -- eapply exec_Sset. terminal_expr.
         -- eapply exec_Sifthenelse with (v1:=Vzero) (b:=false).
            ++ eapply eval_Ebinop; [terminal_expr | constructor |].
               change (Some (Val.of_bool (Int.eq reset_type_value0 Int.one))=Some Vzero).
               rewrite reset_type_not_zoom0. reflexivity.
            ++ reflexivity.
            ++ constructor.
       * terminal_stmt.
   - reflexivity.
   - reflexivity. }
 exists after. split; [exact Hcall |]. split; [exact Hcall |].
 split; [cbn; terminal_load |]. split; [cbn; terminal_load |]. split.
 - intros chunk b ofs Houtside. cbn [dialog_reset_written] in Houtside.
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

Definition dialog_reset_resources_with_memory ge before after
 (r:dialog_reset_resources ge before)
 (Haccess:forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission)
 (Htype:Mem.load Mint8signed after (reset_type ge before r) 0 =
   Some (Vint (reset_type_value ge before r))) : dialog_reset_resources ge after.
Proof.
 destruct r.
 refine {| reset_timer:=reset_timer0; reset_update:=reset_update0;
   reset_scale:=reset_scale0; reset_angle:=reset_angle0; reset_menu:=reset_menu0;
   reset_dialog:=reset_dialog0; reset_page:=reset_page0; reset_choice:=reset_choice0;
   reset_next:=reset_next0; reset_response:=reset_response0; reset_type:=reset_type0;
   reset_transition_function:=reset_transition_function0; reset_type_value:=reset_type_value0 |};
   first [assumption | apply Haccess; assumption].
Defined.

Definition terminal_delayed_written ge before (r:dialog_reset_resources ge before)
 (delayed_timer mode counter special:block) : list block :=
 delayed_timer :: dialog_reset_written ge before r ++ [mode;counter;special].

Definition demo_terminal_delayed_execution_claim : Prop :=
 forall (ge:Clight.genv) (us:bool) before (r:dialog_reset_resources ge before)
   operation delayed_timer debug current stream record mode counter special reset_function warp_function,
 Genv.find_symbol ge DT._sDelayedWarpOp = Some operation ->
 Genv.find_symbol ge DT._sDelayedWarpTimer = Some delayed_timer ->
 Genv.find_symbol ge DT._gDebugLevelSelect = Some debug ->
 Genv.find_symbol ge DT._gCurrDemoInput = Some current ->
 Genv.find_symbol ge DT._sCurrPlayMode = Some mode ->
 Genv.find_symbol ge DT._D_80339ECA = Some counter ->
 Genv.find_symbol ge DT._D_80339EE0 = Some special ->
 Genv.find_symbol ge DT._reset_dialog_render_state = Some reset_function ->
 Genv.find_funct_ptr ge reset_function = Some (Internal DM.f_reset_dialog_render_state) ->
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
 reset_type ge before r <> delayed_timer ->
 (forall b, In b [operation;debug;current] ->
   ~ In b (terminal_delayed_written ge before r delayed_timer mode counter special)) ->
 (forall b, In b [delayed_timer; reset_timer ge before r; reset_update ge before r] ->
   ~ In b [mode;counter;special]) ->
 ~ In delayed_timer (dialog_reset_written ge before r) ->
 exists after,
  eval_funcall function_entry2 ge before
   (Internal (if us then DT.f_initiate_delayed_warp else jp_level_update.f_initiate_delayed_warp))
   [] E0 after Vundef /\
  Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
  Mem.load Mint16signed after delayed_timer 0 = Some Vzero /\
  Mem.load Mint16signed after mode 0 = Some (Vint (Int.repr 4)) /\
  Mem.load Mint16signed after special 0 = Some (Vint (Int.repr (-2))) /\
  Mem.load Mint16signed after (reset_timer ge before r) 0 = Some Vzero /\
  Mem.load Mptr after (reset_update ge before r) 0 = Some Vzero /\
  (forall chunk b ofs,
   ~ In b (terminal_delayed_written ge before r delayed_timer mode counter special) ->
   Mem.load chunk after b ofs = Mem.load chunk before b ofs) /\
  (forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b).

Theorem generated_terminal_delayed_warp_executes_us_jp : demo_terminal_delayed_execution_claim.
Proof.
 intros ge us before r operation delayed_timer debug current stream record mode counter special
   reset_function warp_function Hop_symbol Htimer_symbol Hdebug_symbol Hcurrent_symbol
   Hmode_symbol Hcounter_symbol Hspecial_symbol Hreset_symbol Hreset_body Hwarp_symbol Hwarp_body
   Hop Htimer Hdebug Hcurrent Hstream Hwtimer Hwmode Hwcounter Hwspecial Hmc Hms Hcs
   Htype_separate Hread_separate Hwarp_separate Htimer_reset_separate.
 destruct (Mem.valid_access_store before Mint16signed delayed_timer 0 Vzero Hwtimer)
   as [m1 Hs0].
 assert (Haccess1 : forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
   Mem.valid_access m1 chunk b ofs permission) by (intros; demo_access).
 assert (Htype1 : Mem.load Mint8signed m1 (reset_type ge before r) 0 =
   Some (Vint (reset_type_value ge before r))).
 { rewrite (Mem.load_store_other _ _ _ _ _ _ Hs0) by (left; exact Htype_separate).
   exact (reset_type_read ge before r). }
 set (r1 := dialog_reset_resources_with_memory ge before m1 r Haccess1 Htype1).
 assert (Hwritten1 : dialog_reset_written ge m1 r1 = dialog_reset_written ge before r)
   by (unfold r1; destruct r; reflexivity).
 assert (Hrtimer1 : reset_timer ge m1 r1 = reset_timer ge before r)
   by (unfold r1; destruct r; reflexivity).
 assert (Hrupdate1 : reset_update ge m1 r1 = reset_update ge before r)
   by (unfold r1; destruct r; reflexivity).
 destruct (generated_reset_dialog_call_us_jp ge m1 r1)
   as (reset & Hreset_call & Hreset_call_jp & Hreset_timer & Hreset_update & Hreset_frame &
     Hreset_access & Hreset_valid & Hreset_pointer).
 rewrite Hwritten1 in Hreset_frame. rewrite Hrtimer1 in Hreset_timer.
 rewrite Hrupdate1 in Hreset_update.
 assert (Hread_frame : forall chunk b ofs, In b [operation;debug;current] ->
   Mem.load chunk reset b ofs = Mem.load chunk before b ofs).
 { intros chunk b ofs Hread. rewrite Hreset_frame.
   - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs0) by
       (left; intro Heq; apply (Hread_separate b Hread);
        unfold terminal_delayed_written; left; congruence).
     reflexivity.
   - intro Hin. apply (Hread_separate b Hread). unfold terminal_delayed_written.
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
     unfold terminal_delayed_written; right; apply in_or_app; right; cbn; intuition congruence).
   exact Hop_reset.
 - split.
   + rewrite Hwarp_frame by (intro Heq;
       apply (Hwarp_separate delayed_timer ltac:(cbn; tauto)); cbn; intuition congruence).
     rewrite Hreset_frame by exact Htimer_reset_separate.
     rewrite (Mem.load_store_same _ _ _ _ _ _ Hs0). reflexivity.
   + split; [exact Hmode_after |]. split; [exact Hspecial_after |].
     split.
     * rewrite Hwarp_frame by (intro Heq;
         apply (Hwarp_separate (reset_timer ge before r) ltac:(cbn; tauto));
         cbn; intuition congruence). exact Hreset_timer.
     * split.
       -- rewrite Hwarp_frame by (intro Heq;
            apply (Hwarp_separate (reset_update ge before r) ltac:(cbn; tauto));
            cbn; intuition congruence). exact Hreset_update.
       -- split.
          ++ intros chunk b ofs Houtside. unfold terminal_delayed_written in Houtside.
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

Definition demo_delayed_warp_execution_claim : Prop :=
 demo_terminal_delayed_execution_claim /\ demo_bounded_countdown_execution_claim.

Theorem generated_demo_delayed_warp_execution_us_jp : demo_delayed_warp_execution_claim.
Proof. split; [exact generated_terminal_delayed_warp_executes_us_jp |
 exact generated_bounded_demo_countdown_executes_us_jp]. Qed.
