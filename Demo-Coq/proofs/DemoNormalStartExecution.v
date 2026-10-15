From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update us_area jp_area.
From Demo.Proofs Require Import DemoStartExecution DemoGameplayBoundary
  DemoStartSchedulingExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module N := us_level_update.
Module UI := us_area.

Definition normal_demo_prefix (body : statement) : statement :=
  match body with Ssequence prefix _ => prefix | _ => Sskip end.

Lemma generated_normal_demo_prefix_identical_us_jp :
  normal_demo_prefix (fn_body N.f_play_mode_normal) =
  normal_demo_prefix (fn_body jp_level_update.f_play_mode_normal).
Proof. reflexivity. Qed.

Definition normal_demo_intro (us : bool) : function :=
  if us then UI.f_print_intro_text else jp_area.f_print_intro_text.

(** The UI bodies contain different private string atoms.  Select each real
    version's function; do not identify those atoms across translation units. *)
Lemma generated_intro_text_callee_private_atoms_differ :
  UI.f_print_intro_text <> jp_area.f_print_intro_text.
Proof. intro H. discriminate H. Qed.

Definition intro_public_guard (body : statement)
    : option (statement * expr * statement) :=
  match body with
  | Ssequence read (Sifthenelse guard _ idle) => Some (read, guard, idle)
  | _ => None
  end.

Lemma generated_intro_public_guard_identical_us_jp :
  intro_public_guard (fn_body UI.f_print_intro_text) =
  intro_public_guard (fn_body jp_area.f_print_intro_text).
Proof. reflexivity. Qed.

Definition normal_demo_trigger (us : bool) : function :=
  if us then N.f_level_trigger_warp else jp_level_update.f_level_trigger_warp.

(** Every field names an actual generated object or a concrete CompCert access.
    This is a packaging of the proved scheduler's starting-memory premises,
    not an assumed scheduler execution or gameplay preservation property. *)
Record normal_demo_schedule_memory (ge : Clight.genv) (m : mem) : Type := {
  normal_layout : demo_transition_store_layout ge;
  normal_mario : block;
  normal_mario_co : composite;
  normal_argument : block;
  normal_operation : block;
  normal_timer : block;
  normal_source : block;
  normal_saved : block;
  normal_transition : block;
  normal_framebuffer : block;
  normal_red : block;
  normal_green : block;
  normal_blue : block;
  normal_rgb_function : block;
  normal_transition_function : block;
  normal_mario_lookup : (genv_cenv ge) ! N._MarioState = Some normal_mario_co;
  normal_invinc_offset : field_offset (genv_cenv ge) N._invincTimer
    (co_members normal_mario_co) = OK (38, Full);
  normal_argument_symbol : Genv.find_symbol ge N._sDelayedWarpArg = Some normal_argument;
  normal_operation_symbol : Genv.find_symbol ge N._sDelayedWarpOp = Some normal_operation;
  normal_timer_symbol : Genv.find_symbol ge N._sDelayedWarpTimer = Some normal_timer;
  normal_source_symbol : Genv.find_symbol ge N._sSourceWarpNodeId = Some normal_source;
  normal_saved_symbol : Genv.find_symbol ge N._gSavedCourseNum = Some normal_saved;
  normal_transition_symbol : Genv.find_symbol ge UI._gWarpTransition = Some normal_transition;
  normal_framebuffer_symbol : Genv.find_symbol ge UI._gWarpTransFBSetColor = Some normal_framebuffer;
  normal_red_symbol : Genv.find_symbol ge UI._gWarpTransRed = Some normal_red;
  normal_green_symbol : Genv.find_symbol ge UI._gWarpTransGreen = Some normal_green;
  normal_blue_symbol : Genv.find_symbol ge UI._gWarpTransBlue = Some normal_blue;
  normal_rgb_symbol : Genv.find_symbol ge UI._set_warp_transition_rgb = Some normal_rgb_function;
  normal_rgb_body : Genv.find_funct_ptr ge normal_rgb_function =
    Some (Internal UI.f_set_warp_transition_rgb);
  normal_transition_function_symbol : Genv.find_symbol ge N._play_transition =
    Some normal_transition_function;
  normal_transition_body : Genv.find_funct_ptr ge normal_transition_function =
    Some (Internal UI.f_play_transition);
  normal_operation_separation : forall b,
    In b [normal_timer; normal_source; normal_saved; normal_transition;
          normal_framebuffer; normal_red; normal_green; normal_blue] -> normal_operation <> b;
  normal_timer_separation : forall b,
    In b [normal_source; normal_saved; normal_transition;
          normal_framebuffer; normal_red; normal_green; normal_blue] -> normal_timer <> b;
  normal_no_operation : Mem.load Mint16signed m normal_operation 0 = Some Vzero;
  normal_mario_writable : Mem.valid_access m Mint16signed normal_mario 38 Writable;
  normal_argument_writable : Mem.valid_access m Mint32 normal_argument 0 Writable;
  normal_operation_writable : Mem.valid_access m Mint16signed normal_operation 0 Writable;
  normal_timer_writable : Mem.valid_access m Mint16signed normal_timer 0 Writable;
  normal_source_writable : Mem.valid_access m Mint16signed normal_source 0 Writable;
  normal_saved_writable : Mem.valid_access m Mint16signed normal_saved 0 Writable;
  normal_transition_writable : Mem.range_perm m normal_transition 0 22 Cur Writable;
  normal_framebuffer_writable : Mem.valid_access m Mint32 normal_framebuffer 0 Writable;
  normal_red_writable : Mem.valid_access m Mint8unsigned normal_red 0 Writable;
  normal_green_writable : Mem.valid_access m Mint8unsigned normal_green 0 Writable;
  normal_blue_writable : Mem.valid_access m Mint8unsigned normal_blue 0 Writable
}.

Ltac normal_reduce :=
  first
  [match goal with
   | H : Int.and ?buttons (Int.shl Int.one (Int.repr 7)) = Int.zero |- _ = ?out =>
       change (Some (Vint (Int.and buttons (Int.shl Int.one (Int.repr 7)))) = out);
       rewrite H; reflexivity
   end
  |match goal with
   | H : Int.eq (Int.and ?buttons (Int.repr 4096)) Int.zero = false |- _ = ?out =>
       change (Some (Vint (if Int.eq (Int.and buttons (Int.repr 4096)) Int.zero
         then Int.zero else Int.one)) = out);
       rewrite H; reflexivity
   end
  |scheduling_reduce].

Ltac normal_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [normal_expr | normal_expr | normal_reduce]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [normal_expr | normal_reduce]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [normal_expr | normal_reduce]
  | _ => scheduling_expr
  end.

Ltac normal_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
      [normal_stmt | normal_stmt]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
      [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
        [normal_expr | reflexivity | normal_stmt]
      |eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
        [normal_expr | reflexivity | normal_stmt]]
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; normal_expr
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | normal_expr | scheduling_arguments |
       cbn; eassumption |
       first [reflexivity |
         match goal with |- context [normal_demo_trigger ?version] =>
           destruct version; reflexivity end] |
       eassumption]
  end.

Definition demo_normal_start_execution_claim : Prop :=
  forall (ge : Clight.genv) us before shown
      (setup : normal_demo_schedule_memory ge shown) le ui_trace
      current stream record intro_function player controller controller_co
      mario_global trigger_function buttons,
    Genv.find_symbol ge N._gCurrDemoInput = Some current ->
    Mem.load Mptr before current 0 = Some (Vptr stream record) ->
    Mem.weak_valid_pointer before stream (Ptrofs.unsigned record) = true ->
    Genv.find_symbol ge N._print_intro_text = Some intro_function ->
    Genv.find_funct_ptr ge intro_function = Some (Internal (normal_demo_intro us)) ->
    eval_funcall function_entry2 ge before (Internal (normal_demo_intro us))
      [] ui_trace shown Vundef ->
    Genv.find_symbol ge N._gPlayer1Controller = Some player ->
    Mem.load Mptr shown player 0 = Some (Vptr controller Ptrofs.zero) ->
    (genv_cenv ge) ! N._Controller = Some controller_co ->
    field_offset (genv_cenv ge) N._buttonPressed (co_members controller_co) = OK (18, Full) ->
    Mem.load Mint16unsigned shown controller 18 = Some (Vint buttons) ->
    Int.and buttons (Int.shl Int.one (Int.repr 7)) = Int.zero ->
    Int.eq (Int.and buttons (Int.repr 4096)) Int.zero = false ->
    Mem.load Mint8unsigned shown (normal_transition ge shown setup) 0 = Some Vzero ->
    Genv.find_symbol ge N._gMarioState = Some mario_global ->
    Mem.load Mptr shown mario_global 0 = Some (Vptr (normal_mario ge shown setup) Ptrofs.zero) ->
    Genv.find_symbol ge N._level_trigger_warp = Some trigger_function ->
    Genv.find_funct_ptr ge trigger_function = Some (Internal (normal_demo_trigger us)) ->
    exists after le',
      exec_stmt function_entry2 ge empty_env le before
        (normal_demo_prefix (fn_body N.f_play_mode_normal)) ui_trace le' after Out_normal /\
      exec_stmt function_entry2 ge empty_env le before
        (normal_demo_prefix (fn_body jp_level_update.f_play_mode_normal))
        ui_trace le' after Out_normal /\
      Mem.load Mint16signed after (normal_operation ge shown setup) 0 =
        Some (Vint (Int.repr 22)) /\
      Mem.load Mint16signed after (normal_timer ge shown setup) 0 =
        Some (Vint (Int.repr 20)) /\
      (forall chunk b ofs p,
        Mem.valid_access shown chunk b ofs p ->
        Mem.valid_access after chunk b ofs p) /\
      (forall chunk b ofs,
        ~ In b [normal_mario ge shown setup; normal_argument ge shown setup;
          normal_operation ge shown setup; normal_timer ge shown setup;
          normal_source ge shown setup; normal_saved ge shown setup;
          normal_transition ge shown setup; normal_framebuffer ge shown setup;
          normal_red ge shown setup; normal_green ge shown setup; normal_blue ge shown setup] ->
        Mem.load chunk after b ofs = Mem.load chunk shown b ofs).

Theorem generated_normal_demo_start_prefix_executes :
  demo_normal_start_execution_claim.
Proof.
  intros ge us before shown setup le ui_trace current stream record
    intro_function player controller controller_co mario_global trigger_function buttons
    Hcurrent Hpointer Hvalid Hintro Hintro_body Hintro_call
    Hplayer Hcontroller Hcontroller_co Hbuttonoffset Hbuttons Hend Hstart
    Hinactive Hmario_global Hmario_pointer Htrigger Htrigger_body.
  destruct setup as [layout mario mario_co argument operation timer source saved
    transition framebuffer red green blue rgb_function transition_function
    Hmario_co Hinvinc Hargument Hoperation Htimer Hsource Hsaved Htransition
    Hframebuffer Hred Hgreen Hblue Hrgb_function Hrgb_body
    Htransition_function Htransition_body Hopsep Htimersep Hnone
    Hwmario Hwargument Hwoperation Hwtimer Hwsource Hwsaved Hrange Hwf Hwr Hwg Hwb].
  cbn in Hinactive, Hmario_pointer |- *.
  destruct (generated_demo_next_is_really_scheduled_us_jp ge layout shown
    mario mario_co argument operation timer source saved transition framebuffer
    red green blue rgb_function transition_function
    Hmario_co Hinvinc Hargument Hoperation Htimer Hsource Hsaved Htransition
    Hframebuffer Hred Hgreen Hblue Hrgb_function Hrgb_body
    Htransition_function Htransition_body Hopsep Htimersep Hnone
    Hwmario Hwargument Hwoperation Hwtimer Hwsource Hwsaved Hrange Hwf Hwr Hwg Hwb)
    as [after [Hschedule_us [Hschedule_jp [Hop [Htime Hrest]]]]].
  assert (Hschedule : eval_funcall function_entry2 ge shown
    (Internal (normal_demo_trigger us)) [Vptr mario Ptrofs.zero; Vint (Int.repr 22)]
    E0 after (Vint (Int.repr 20))).
  { destruct us; assumption. }
  destruct layout as [transition_co data_co Htransition_co Hdata_co Hmembers Hdata_members Halign].
  assert (Hactiveoffset : field_offset (genv_cenv ge) N._isActive
    (co_members transition_co) = OK (0, Full)).
  { rewrite Hmembers. reflexivity. }
  assert (Hexec : exists le', exec_stmt function_entry2 ge empty_env le before
    (normal_demo_prefix (fn_body N.f_play_mode_normal)) ui_trace le' after Out_normal).
  { eexists. unfold normal_demo_prefix. cbn [N.f_play_mode_normal fn_body].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := ui_trace).
    - eapply exec_Sset. scheduling_expr.
    - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
      + eapply eval_Ebinop with (v1 := Vptr stream record) (v2 := Vzero).
        * eapply eval_Etempvar. apply PTree.gss.
        * eapply eval_Ecast; [constructor | reflexivity].
        * change (option_map Val.of_bool
            (if Mem.weak_valid_pointer before stream (Ptrofs.unsigned record)
             then Some true else None) = Some (Vint Int.one)).
          rewrite Hvalid. reflexivity.
      + reflexivity.
      + replace ui_trace with (ui_trace ++ E0) at 1 by apply app_nil_r.
        eapply exec_Sseq_1 with (t1 := ui_trace) (t2 := E0).
        * eapply exec_Scall with (vf := Vptr intro_function Ptrofs.zero)
            (f := Internal (normal_demo_intro us)) (vargs := []) (vres := Vundef).
          -- reflexivity.
          -- scheduling_expr.
          -- constructor.
          -- cbn. exact Hintro_body.
          -- destruct us; reflexivity.
          -- exact Hintro_call.
        * normal_stmt. }
  destruct Hexec as [le' Hexec]. exists after, le'. split; [exact Hexec |].
  split.
  - exact Hexec.
  - split; [exact Hop |]. split; [exact Htime | exact Hrest].
Qed.
