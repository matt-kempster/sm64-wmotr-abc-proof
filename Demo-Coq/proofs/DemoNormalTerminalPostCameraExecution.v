From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
 Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update us_ingame_menu.
From Demo.Proofs Require Import DemoStartExecution DemoGameplayBoundary
 DemoNormalPostCameraExecution DemoNormalDelayedExecution DemoDialogZoomExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module DT := us_level_update.
Module DM := us_ingame_menu.

(** The generated painting-null function still allocates/frees its local WarpNode.
    Its complete call preserves every byte and permission of every entry block. *)
Lemma generated_painting_null_complete_byte_frame :
 forall (ge:Clight.genv) before current area area_co,
 Genv.find_symbol ge DT._gCurrentArea = Some current ->
 Mem.load Mptr before current 0 = Some(Vptr area Ptrofs.zero) ->
 (genv_cenv ge) ! DT._Area = Some area_co ->
 field_offset (genv_cenv ge) DT._paintingWarpNodes (co_members area_co) = OK(24,Full) ->
 Mem.load Mptr before area 24 = Some Vzero ->
 exists after,
  eval_funcall function_entry2 ge before (Internal DT.f_initiate_painting_warp) [] E0 after Vundef /\
  Mem.unchanged_on (fun _ _ => True) before after.
Proof.
 intros ge before current area area_co Hcurrent Harea Hco Hoffset Htable.
 set(extent:=sizeof(genv_cenv ge)(Tstruct DT._WarpNode noattr)).
 destruct(Mem.alloc before 0 extent) as[allocated stack]eqn:Halloc.
 destruct(Mem.range_perm_free allocated stack 0 extent
   ltac:(intros ofs Hrange;eapply Mem.perm_alloc_2;eassumption))as[after Hfree].
 exists after;split.
 - eapply eval_funcall_internal with(e:=painting_stack_env stack)
     (le1:=create_undef_temps(fn_temps DT.f_initiate_painting_warp))
     (m1:=allocated)(m2:=allocated)(out:=Out_normal).
   + apply function_entry2_intro.
     * constructor;[cbn;tauto|constructor].
     * constructor.
     * unfold list_disjoint;cbn;tauto.
     * eapply alloc_variables_cons with(m1:=allocated)(b1:=stack);[exact Halloc|constructor].
     * reflexivity.
   + eapply generated_painting_warp_null_table_from_loads with
       (global:=current)(area:=area)(offset:=Ptrofs.zero)(co:=area_co)(field_offset:=24);
       try eassumption;first[reflexivity|eapply Mem.load_alloc_other;eassumption].
   + reflexivity.
   + change(Mem.free_list allocated[(stack,0,extent)]=Some after).
     cbn -[Mem.free extent];rewrite Hfree;reflexivity.
 - apply Mem.unchanged_on_implies with(P:=fun b byte => Mem.valid_block before b).
   + eapply Mem.unchanged_on_trans with(m2:=allocated).
     * eapply Mem.alloc_unchanged_on;exact Halloc.
     * eapply Mem.free_unchanged_on;[exact Hfree|].
       intros byte Hrange Hvalid. exact(Mem.fresh_block_alloc _ _ _ _ _ Halloc Hvalid).
   + intros b byte Htrue Hvalid;exact Hvalid.
Qed.

Lemma complete_byte_frame_access : forall before after,
 Mem.unchanged_on(fun _ _=>True)before after ->
 forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
 Mem.valid_access after chunk b ofs permission.
Proof.
 intros before after Hframe chunk b ofs permission[Hrange Halign]. split;[|exact Halign].
 intros byte Hbyte. eapply Mem.perm_unchanged_on;[exact Hframe|exact I|].
 apply Hrange;exact Hbyte.
Qed.

Lemma complete_byte_frame_weak_pointer : forall before after,
 Mem.unchanged_on(fun _ _=>True)before after ->
 forall b ofs, Mem.weak_valid_pointer before b ofs=true ->
 Mem.weak_valid_pointer after b ofs=true.
Proof.
 intros before after Hframe b ofs Hvalid.
 apply Mem.weak_valid_pointer_spec in Hvalid. apply Mem.weak_valid_pointer_spec.
 destruct Hvalid as[Hvalid|Hvalid];[left|right];
 apply Mem.valid_pointer_nonempty_perm;apply Mem.valid_pointer_nonempty_perm in Hvalid;
 (eapply Mem.perm_unchanged_on;[exact Hframe|exact I|exact Hvalid]).
Qed.

Definition demo_normal_terminal_postcamera_execution_claim : Prop :=
 forall (ge:Clight.genv) (us:bool) le before (r:dialog_any_resources ge before)
   painting_current area area_co painting_function
   operation delayed_timer debug current stream record mode counter special any_function warp_function delayed_function,
 Genv.find_symbol ge DT._gCurrentArea = Some painting_current ->
 Mem.load Mptr before painting_current 0 = Some(Vptr area Ptrofs.zero) ->
 (genv_cenv ge) ! DT._Area = Some area_co ->
 field_offset (genv_cenv ge) DT._paintingWarpNodes (co_members area_co) = OK(24,Full) ->
 Mem.load Mptr before area 24 = Some Vzero ->
 Genv.find_symbol ge DT._initiate_painting_warp = Some painting_function ->
 Genv.find_funct_ptr ge painting_function = Some(Internal DT.f_initiate_painting_warp) ->
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
   (normal_postcamera_suffix (fn_body
     (if us then DT.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
   E0 (PTree.set DT._t'6 (Vint (Int.repr 4)) le) after
   (Out_return (Some (Vzero,tint))) /\
  Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
  Mem.load Mint16signed after delayed_timer 0 = Some Vzero /\
  Mem.load Mint16signed after mode 0 = Some (Vint (Int.repr 4)) /\
  Mem.load Mint16signed after special 0 = Some (Vint (Int.repr (-2))) /\
  Mem.load Mint16signed after (any_timer ge before r) 0 = Some Vzero /\
  Mem.load Mptr after (any_update ge before r) 0 = Some Vzero /\
  (forall chunk b ofs, Mem.valid_block before b ->
   ~ In b (terminal_any_written ge before r delayed_timer mode counter special) ->
   Mem.load chunk after b ofs = Mem.load chunk before b ofs) /\
  (forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b).



Theorem generated_normal_terminal_postcamera_interval_executes_us_jp :
 demo_normal_terminal_postcamera_execution_claim.
Proof.
 intros ge us le before r painting_current area area_co painting_function
   operation delayed_timer debug current stream record mode counter special
   any_function warp_function delayed_function Hpainting_current Harea Harea_co Hpainting_offset
   Hnull Hpainting_symbol Hpainting_body Hop_symbol Htimer_symbol Hdebug_symbol Hcurrent_symbol
   Hmode_symbol Hcounter_symbol Hspecial_symbol Hreset_symbol Hreset_body Hwarp_symbol Hwarp_body
   Hop Htimer Hdebug Hcurrent Hstream Hwtimer Hwmode Hwcounter Hwspecial Hmc Hms Hcs
   Htype_separate Hcamera_separate Hread_separate Hwarp_separate Htimer_reset_separate
   Hdelayed_symbol Hdelayed_body.
 destruct(generated_painting_null_complete_byte_frame ge before painting_current area area_co
   Hpainting_current Harea Harea_co Hpainting_offset Hnull)
   as(painted&Hpainting&Hpainting_bytes).
 pose proof(complete_byte_frame_access before painted Hpainting_bytes)as Hpainting_access.
 assert(Hpainting_reads:forall chunk b ofs value,Mem.load chunk before b ofs=Some value ->
   Mem.load chunk painted b ofs=Some value).
 { intros chunk b ofs value Hread. eapply Mem.load_unchanged_on;
     [exact Hpainting_bytes|intros;exact I|exact Hread]. }
 set(rp:=dialog_any_resources_with_memory ge before painted r Hpainting_access
   (Hpainting_reads _ _ _ _ (any_type_read ge before r))
   (Hpainting_reads _ _ _ _ (any_camera_read ge before r))).
 assert(Htypep:any_type ge painted rp=any_type ge before r)
   by(unfold rp;destruct r;reflexivity).
 assert(Hcamerap:any_camera_global ge painted rp=any_camera_global ge before r)
   by(unfold rp;destruct r;reflexivity).
 assert(Htimerp:any_timer ge painted rp=any_timer ge before r)
   by(unfold rp;destruct r;reflexivity).
 assert(Hupdatep:any_update ge painted rp=any_update ge before r)
   by(unfold rp;destruct r;reflexivity).
 assert(Hwrittenp:dialog_any_written ge painted rp=dialog_any_written ge before r)
   by(unfold rp;destruct r;reflexivity).
 assert(Hterminalp:terminal_any_written ge painted rp delayed_timer mode counter special=
   terminal_any_written ge before r delayed_timer mode counter special).
 { unfold terminal_any_written;rewrite Hwrittenp;reflexivity. }
 assert(Hread_separatep:forall b,In b[operation;debug;current]->
   ~In b(terminal_any_written ge painted rp delayed_timer mode counter special)).
 { intros b Hin;rewrite Hterminalp;apply Hread_separate;exact Hin. }
 assert(Hwarp_separatep:forall b,In b[delayed_timer;any_timer ge painted rp;any_update ge painted rp]->
   ~In b[mode;counter;special]).
 { rewrite Htimerp,Hupdatep;exact Hwarp_separate. }
 destruct(generated_normal_any_dialog_terminal_suffix_executes_us_jp ge true le painted rp
   operation delayed_timer debug current stream record mode counter special any_function
   warp_function delayed_function Hop_symbol Htimer_symbol Hdebug_symbol Hcurrent_symbol
   Hmode_symbol Hcounter_symbol Hspecial_symbol Hreset_symbol Hreset_body Hwarp_symbol Hwarp_body
   (Hpainting_reads _ _ _ _ Hop)(Hpainting_reads _ _ _ _ Htimer)
   (Hpainting_reads _ _ _ _ Hdebug)(Hpainting_reads _ _ _ _ Hcurrent)
   (complete_byte_frame_weak_pointer before painted Hpainting_bytes _ _ Hstream)
   (Hpainting_access _ _ _ _ Hwtimer)(Hpainting_access _ _ _ _ Hwmode)
   (Hpainting_access _ _ _ _ Hwcounter)(Hpainting_access _ _ _ _ Hwspecial)
   Hmc Hms Hcs ltac:(rewrite Htypep;exact Htype_separate)
   ltac:(rewrite Hcamerap;exact Hcamera_separate) Hread_separatep Hwarp_separatep
   ltac:(rewrite Hwrittenp;exact Htimer_reset_separate) Hdelayed_symbol Hdelayed_body)
   as(after&Hsuffix&Hop_after&Htimer_after&Hmode_after&Hspecial_after&Htransition_after&
     Hupdate_after&Hframe&Haccess&Hvalid).
 rewrite Htimerp in Htransition_after. rewrite Hupdatep in Hupdate_after.
 rewrite Hterminalp in Hframe.
 exists after;split.
 - assert(Hselected:normal_postcamera_suffix(fn_body
     (if us then DT.f_play_mode_normal else jp_level_update.f_play_mode_normal))=
     normal_postcamera_suffix(fn_body DT.f_play_mode_normal))by(destruct us;reflexivity).
   rewrite Hselected.
   change(exec_stmt function_entry2 ge empty_env le before
     (Ssequence(Scall None(Evar DT._initiate_painting_warp(Tfunction[]tvoid cc_default))[])
       (normal_afterpainting_suffix(fn_body DT.f_play_mode_normal)))
     E0(PTree.set DT._t'6(Vint(Int.repr 4))le)after(Out_return(Some(Vzero,tint)))).
   eapply exec_Sseq_1 with(t1:=E0)(t2:=E0)(le1:=le)(m1:=painted).
   + eapply exec_Scall with(vargs:=[])(vres:=Vundef);
       [reflexivity|demo_expr|constructor|cbn;exact Hpainting_body|reflexivity|exact Hpainting].
   + exact Hsuffix.
 - do 6(split;[assumption|]). split.
   + intros chunk b ofs Hinitial Houtside. rewrite Hframe by exact Houtside.
     eapply Mem.load_unchanged_on_1;[exact Hpainting_bytes|exact Hinitial|intros;exact I].
   + split.
     * intros chunk b ofs permission Hresource. apply Haccess,Hpainting_access,Hresource.
     * intros b Hinitial. apply Hvalid. eapply Mem.valid_block_unchanged_on;eassumption.
Qed.
