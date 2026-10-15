From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Coqlib Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update.
From Demo.Proofs Require Import DemoStartExecution DemoDispatchFacts.
Import ListNotations.
Local Open Scope Z_scope.
Module G := us_level_update.

(** This is the actual complete generated painting-warp body.  The null-table
    path does not inspect Mario, the floor, a warp destination or any callee.
    Temporary updates are harmless; the memory and observable trace are exactly
    unchanged.  This is stronger than the painting-opcode syntax certificate,
    but the construction/preservation of the null table is still separate. *)

Definition painting_area_read : expr :=
  Evar G._gCurrentArea (tptr (Tstruct G._Area noattr)).

Definition painting_table_read : expr :=
  Efield
    (Ederef (Etempvar G._t'17 (tptr (Tstruct G._Area noattr)))
      (Tstruct G._Area noattr)) G._paintingWarpNodes
    (tptr (Tstruct G._WarpNode noattr)).

Definition painting_null_temps (le : temp_env) (area : val) : temp_env :=
  PTree.set G._t'3 Vzero
    (PTree.set G._t'18 Vzero (PTree.set G._t'17 area le)).

Lemma generated_painting_body_identical_us_jp :
  fn_body G.f_initiate_painting_warp =
  fn_body jp_level_update.f_initiate_painting_warp.
Proof. reflexivity. Qed.

Theorem generated_painting_warp_null_table_executes :
  forall ge e le m area,
    eval_expr ge e le m painting_area_read area ->
    eval_expr ge e (PTree.set G._t'17 area le) m
      painting_table_read Vzero ->
    exec_stmt function_entry2 ge e le m
      (fn_body G.f_initiate_painting_warp) E0
      (painting_null_temps le area) m Out_normal.
Proof.
  intros ge e le m area Harea Htable.
  unfold painting_null_temps.
  cbn [G.f_initiate_painting_warp fn_body].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sset. exact Harea.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset. exact Htable.
      * eapply exec_Sifthenelse with (v1 := Vzero) (b := false).
        -- eapply eval_Ebinop with (v1 := Vzero) (v2 := Vzero).
           ++ eapply eval_Etempvar. apply PTree.gss.
           ++ eapply eval_Ecast.
              ** constructor.
              ** reflexivity.
           ++ reflexivity.
        -- reflexivity.
        -- eapply exec_Sset. constructor.
  - eapply exec_Sifthenelse with (v1 := Vzero) (b := false).
    + eapply eval_Etempvar. apply PTree.gss.
    + reflexivity.
    + constructor.
Qed.

(** The two premises above are exactly two generated reads, rather than an
    assumed execution or preservation property.  Here they are reduced further
    to symbol/layout/load facts, the form an area-initialization proof can use. *)
Theorem generated_painting_warp_null_table_from_loads :
  forall (ge : Clight.genv) (e : env) le m global area offset co field_offset,
    e ! G._gCurrentArea = None ->
    Genv.find_symbol ge G._gCurrentArea = Some global ->
    Mem.load Mptr m global 0 = Some (Vptr area offset) ->
    (genv_cenv ge) ! G._Area = Some co ->
    Ctypes.field_offset (genv_cenv ge) G._paintingWarpNodes
      (co_members co) = OK (field_offset, Full) ->
    Mem.load Mptr m area
      (Ptrofs.unsigned (Ptrofs.add offset (Ptrofs.repr field_offset))) =
      Some Vzero ->
    exec_stmt function_entry2 ge e le m
      (fn_body G.f_initiate_painting_warp) E0
      (painting_null_temps le (Vptr area offset)) m Out_normal.
Proof.
  intros ge e le m global area offset co field_offset
    Hlocal Hsymbol Harea Hco Hfield Htable.
  apply generated_painting_warp_null_table_executes.
  - unfold painting_area_read.
    eapply eval_Elvalue.
    + eapply eval_Evar_global; eassumption.
    + eapply deref_loc_value; [reflexivity | exact Harea].
  - unfold painting_table_read.
    eapply eval_Elvalue.
    + eapply eval_Efield_struct with (co := co) (delta := field_offset).
      * eapply eval_Elvalue.
        -- eapply eval_Ederef. eapply eval_Etempvar. apply PTree.gss.
        -- eapply deref_loc_copy. reflexivity.
      * reflexivity.
      * exact Hco.
      * exact Hfield.
    + eapply deref_loc_value; [reflexivity | exact Htable].
Qed.

Definition painting_null_memory_execution_claim : Prop :=
  forall ge e le m area,
    eval_expr ge e le m painting_area_read area ->
    eval_expr ge e (PTree.set G._t'17 area le) m
      painting_table_read Vzero ->
    exec_stmt function_entry2 ge e le m
      (fn_body G.f_initiate_painting_warp) E0
      (painting_null_temps le area) m Out_normal /\
    exec_stmt function_entry2 ge e le m
      (fn_body jp_level_update.f_initiate_painting_warp) E0
      (painting_null_temps le area) m Out_normal.

Theorem generated_painting_null_memory_execution_us_jp :
  painting_null_memory_execution_claim.
Proof.
  intros ge e le m area Harea Htable.
  split; apply generated_painting_warp_null_table_executes; assumption.
Qed.

(** The delayed-demo branch calls this real generated internal function.  Its
    effect is three named stores; in particular it does not install the level
    of an ordinary object/death/star warp.  The function-entry and cleanup
    obligations are proved here rather than postulating a callee execution. *)
Definition warp_special_entry_temps (arg : int) : temp_env :=
  PTree.set G._arg (Vint arg) (PTree.empty _).

Lemma generated_warp_special_identical_us_jp :
  G.f_warp_special = jp_level_update.f_warp_special.
Proof. reflexivity. Qed.

Theorem generated_warp_special_call_executes :
  forall (ge : Clight.genv) before mode timer special arg,
    Genv.find_symbol ge G._sCurrPlayMode = Some mode ->
    Genv.find_symbol ge G._D_80339ECA = Some timer ->
    Genv.find_symbol ge G._D_80339EE0 = Some special ->
    mode <> timer -> mode <> special -> timer <> special ->
    Mem.valid_access before Mint16signed mode 0 Writable ->
    Mem.valid_access before Mint16unsigned timer 0 Writable ->
    Mem.valid_access before Mint16signed special 0 Writable ->
    exists m1 m2 after,
      Mem.store Mint16signed before mode 0 (Vint (Int.repr 4)) = Some m1 /\
      Mem.store Mint16unsigned m1 timer 0 Vzero = Some m2 /\
      Mem.store Mint16signed m2 special 0
        (Vint (Int.sign_ext 16 arg)) = Some after /\
      eval_funcall function_entry2 ge before (Internal G.f_warp_special)
        [Vint arg] E0 after Vundef /\
      Mem.load Mint16signed after mode 0 = Some (Vint (Int.repr 4)) /\
      Mem.load Mint16signed after special 0 =
        Some (Vint (Int.sign_ext 16 arg)) /\
      (forall chunk b ofs,
        b <> mode -> b <> timer -> b <> special ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).
Proof.
  intros ge before mode timer special arg Hmode Htimer Hspecial
    Hmt Hms Hts Hwmode Hwtimer Hwspecial.
  destruct (Mem.valid_access_store before Mint16signed mode 0
    (Vint (Int.repr 4)) ltac:(demo_access)) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint16unsigned timer 0 Vzero
    ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint16signed special 0
    (Vint (Int.sign_ext 16 arg)) ltac:(demo_access)) as [after Hs3].
  exists m1, m2, after. repeat split; try assumption.
  - eapply eval_funcall_internal with (e := empty_env)
      (le1 := warp_special_entry_temps arg) (le2 := warp_special_entry_temps arg)
      (m1 := before) (m2 := after) (out := Out_normal).
    + constructor.
      * constructor.
      * constructor; [cbn; tauto | constructor].
      * unfold list_disjoint. cbn. tauto.
      * constructor.
      * reflexivity.
    + cbn [G.f_warp_special fn_body]. unfold warp_special_entry_temps.
      demo_stmt.
    + reflexivity.
    + reflexivity.
  - demo_load.
  - rewrite (Mem.load_store_same _ _ _ _ _ _ Hs3).
    cbn. rewrite Int.sign_ext_idem by lia. reflexivity.
  - intros chunk b ofs Hbm Hbt Hbs.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; congruence).
    reflexivity.
Qed.

Definition delayed_demo_active_body : statement :=
  match delayed_demo_choice (fn_body G.f_initiate_delayed_warp) with
  | Some (_, _, body) => body
  | None => Sskip
  end.

Definition delayed_demo_exit_code (op : int) : int :=
  if Int.eq op (Int.repr 25) then Int.neg (Int.repr 8)
  else Int.neg (Int.repr 2).

(** This theorem executes the selected active-demo body, including the internal
    warp_special call.  Its entry is after the debug choice and demo-pointer
    non-null test.  Reaching that entry is a separate obligation; the result is
    a negative script control code, not an ordinary positive level number. *)
Theorem generated_active_demo_delayed_branch_executes :
  forall (ge : Clight.genv) le before operation mode timer special function_block op,
    Genv.find_symbol ge G._sDelayedWarpOp = Some operation ->
    Genv.find_symbol ge G._sCurrPlayMode = Some mode ->
    Genv.find_symbol ge G._D_80339ECA = Some timer ->
    Genv.find_symbol ge G._D_80339EE0 = Some special ->
    Genv.find_symbol ge G._warp_special = Some function_block ->
    Genv.find_funct_ptr ge function_block = Some (Internal G.f_warp_special) ->
    mode <> timer -> mode <> special -> timer <> special ->
    Mem.load Mint16signed before operation 0 = Some (Vint op) ->
    Mem.valid_access before Mint16signed mode 0 Writable ->
    Mem.valid_access before Mint16unsigned timer 0 Writable ->
    Mem.valid_access before Mint16signed special 0 Writable ->
    exists after,
      exec_stmt function_entry2 ge empty_env le before delayed_demo_active_body
        E0 (PTree.set G._t'26 (Vint op) le) after Out_normal /\
      Mem.load Mint16signed after mode 0 = Some (Vint (Int.repr 4)) /\
      Mem.load Mint16signed after special 0 =
        Some (Vint (Int.sign_ext 16 (delayed_demo_exit_code op))) /\
      (forall chunk b ofs,
        b <> mode -> b <> timer -> b <> special ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).
Proof.
  intros ge le before operation mode timer special function_block op
    Hoperation Hmode Htimer Hspecial Hfunction Hbody
    Hmt Hms Hts Hop Hwmode Hwtimer Hwspecial.
  destruct (generated_warp_special_call_executes ge before mode timer special
    (delayed_demo_exit_code op) Hmode Htimer Hspecial Hmt Hms Hts
    Hwmode Hwtimer Hwspecial)
    as (m1 & m2 & after & Hs1 & Hs2 & Hs3 & Hcall & Hmodeafter & Hspecialafter & Hframe).
  exists after. repeat split; try assumption.
  unfold delayed_demo_active_body, delayed_demo_choice.
  cbn [G.f_initiate_delayed_warp fn_body].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sset. demo_expr.
  - unfold delayed_demo_exit_code in Hcall.
    destruct (Int.eq op (Int.repr 25)) eqn:Hchoice.
    + eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
      * eapply eval_Ebinop with (v1 := Vint op) (v2 := Vint (Int.repr 25)).
        -- eapply eval_Etempvar. apply PTree.gss.
        -- constructor.
        -- change (Some (Val.of_bool (Int.eq op (Int.repr 25))) =
             Some (Vint Int.one)). rewrite Hchoice. reflexivity.
      * reflexivity.
      * eapply exec_Scall with (vf := Vptr function_block Ptrofs.zero)
          (f := Internal G.f_warp_special) (vargs := [Vint (Int.neg (Int.repr 8))])
          (vres := Vundef).
        -- reflexivity.
        -- demo_expr.
        -- econstructor.
           ++ eapply eval_Eunop; [constructor | reflexivity].
           ++ reflexivity.
           ++ constructor.
        -- cbn. exact Hbody.
        -- reflexivity.
        -- exact Hcall.
    + eapply exec_Sifthenelse with (v1 := Vzero) (b := false).
      * eapply eval_Ebinop with (v1 := Vint op) (v2 := Vint (Int.repr 25)).
        -- eapply eval_Etempvar. apply PTree.gss.
        -- constructor.
        -- change (Some (Val.of_bool (Int.eq op (Int.repr 25))) =
             Some Vzero). rewrite Hchoice. reflexivity.
      * reflexivity.
      * eapply exec_Scall with (vf := Vptr function_block Ptrofs.zero)
          (f := Internal G.f_warp_special) (vargs := [Vint (Int.neg (Int.repr 2))])
          (vres := Vundef).
        -- reflexivity.
        -- demo_expr.
        -- econstructor.
           ++ eapply eval_Eunop; [constructor | reflexivity].
           ++ reflexivity.
           ++ constructor.
        -- cbn. exact Hbody.
        -- reflexivity.
        -- exact Hcall.
Qed.

Definition delayed_demo_dispatch_body (body : statement) : statement :=
  match body with
  | Ssequence _
      (Sifthenelse _
        (Ssequence _
          (Ssequence _ (Sifthenelse _ _ dispatch))) _) => dispatch
  | _ => Sskip
  end.

Lemma generated_delayed_demo_dispatch_identical_us_jp :
  delayed_demo_dispatch_body (fn_body G.f_initiate_delayed_warp) =
  delayed_demo_dispatch_body
    (fn_body jp_level_update.f_initiate_delayed_warp).
Proof. reflexivity. Qed.

(** This includes the actual demo-pointer load and non-null guard.  It starts
    after reset_dialog_render_state and after the optional debug exit; it does
    not assume that an active pointer causes the desired call.  The branch and
    the complete called internal function are both executed below. *)
Definition nonnull_demo_delayed_dispatch_execution_claim : Prop :=
  forall (ge : Clight.genv) le before current stream record
      operation mode timer special function_block op,
    Genv.find_symbol ge G._gCurrDemoInput = Some current ->
    Genv.find_symbol ge G._sDelayedWarpOp = Some operation ->
    Genv.find_symbol ge G._sCurrPlayMode = Some mode ->
    Genv.find_symbol ge G._D_80339ECA = Some timer ->
    Genv.find_symbol ge G._D_80339EE0 = Some special ->
    Genv.find_symbol ge G._warp_special = Some function_block ->
    Genv.find_funct_ptr ge function_block = Some (Internal G.f_warp_special) ->
    mode <> timer -> mode <> special -> timer <> special ->
    Mem.load Mptr before current 0 = Some (Vptr stream record) ->
    Mem.weak_valid_pointer before stream (Ptrofs.unsigned record) = true ->
    Mem.load Mint16signed before operation 0 = Some (Vint op) ->
    Mem.valid_access before Mint16signed mode 0 Writable ->
    Mem.valid_access before Mint16unsigned timer 0 Writable ->
    Mem.valid_access before Mint16signed special 0 Writable ->
    exists after,
      exec_stmt function_entry2 ge empty_env le before
        (delayed_demo_dispatch_body (fn_body G.f_initiate_delayed_warp)) E0
        (PTree.set G._t'26 (Vint op)
          (PTree.set G._t'5 (Vptr stream record) le)) after Out_normal /\
      exec_stmt function_entry2 ge empty_env le before
        (delayed_demo_dispatch_body
          (fn_body jp_level_update.f_initiate_delayed_warp)) E0
        (PTree.set G._t'26 (Vint op)
          (PTree.set G._t'5 (Vptr stream record) le)) after Out_normal /\
      Mem.load Mint16signed after mode 0 = Some (Vint (Int.repr 4)) /\
      Mem.load Mint16signed after special 0 =
        Some (Vint (Int.sign_ext 16 (delayed_demo_exit_code op))) /\
      (forall chunk b ofs,
        b <> mode -> b <> timer -> b <> special ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).

Theorem generated_nonnull_demo_delayed_dispatch_executes :
  nonnull_demo_delayed_dispatch_execution_claim.
Proof.
  intros ge le before current stream record operation mode timer special
    function_block op Hcurrent Hoperation Hmode Htimer Hspecial
    Hfunction Hbody Hmt Hms Hts Hpointer Hvalid Hop Hwmode Hwtimer Hwspecial.
  destruct (generated_active_demo_delayed_branch_executes ge
    (PTree.set G._t'5 (Vptr stream record) le) before operation mode timer special
    function_block op Hoperation Hmode Htimer Hspecial Hfunction Hbody
    Hmt Hms Hts Hop Hwmode Hwtimer Hwspecial)
    as (after & Hexec & Hmodeafter & Hspecialafter & Hframe).
  assert (Hdispatch : exec_stmt function_entry2 ge empty_env le before
    (delayed_demo_dispatch_body (fn_body G.f_initiate_delayed_warp)) E0
    (PTree.set G._t'26 (Vint op)
      (PTree.set G._t'5 (Vptr stream record) le)) after Out_normal).
  { unfold delayed_demo_dispatch_body.
    cbn [G.f_initiate_delayed_warp fn_body].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    - eapply exec_Sset. demo_expr.
    - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
      + eapply eval_Ebinop with (v1 := Vptr stream record) (v2 := Vzero).
        * eapply eval_Etempvar. apply PTree.gss.
        * eapply eval_Ecast; [constructor | reflexivity].
        * change (option_map Val.of_bool
            (if Mem.weak_valid_pointer before stream (Ptrofs.unsigned record)
             then Some true else None) = Some (Vint Int.one)).
          rewrite Hvalid. reflexivity.
      + reflexivity.
      + exact Hexec. }
  exists after. split; [exact Hdispatch |].
  split.
  - rewrite <- generated_delayed_demo_dispatch_identical_us_jp. exact Hdispatch.
  - repeat split; assumption.
Qed.

Lemma delayed_demo_exit_code_is_negative_control :
  forall op,
    Int.signed (Int.sign_ext 16 (delayed_demo_exit_code op)) = -8 \/
    Int.signed (Int.sign_ext 16 (delayed_demo_exit_code op)) = -2.
Proof.
  intros op. unfold delayed_demo_exit_code.
  destruct (Int.eq op (Int.repr 25)); vm_compute; auto.
Qed.

Record demo_transition_layout (ge : Clight.genv) : Type := {
  transition_hud_composite : composite;
  transition_warp_composite : composite;
  transition_hud_lookup : (genv_cenv ge) ! G._HudDisplay =
    Some transition_hud_composite;
  transition_warp_lookup : (genv_cenv ge) ! G._WarpDest =
    Some transition_warp_composite;
  transition_hud_flags : field_offset (genv_cenv ge) G._flags
    (co_members transition_hud_composite) = OK (10, Full);
  transition_warp_type : field_offset (genv_cenv ge) G._type
    (co_members transition_warp_composite) = OK (0, Full)
}.

Definition transition_hud_members : members :=
  [Member_plain G._lives tshort; Member_plain G._coins tshort;
   Member_plain G._stars tshort; Member_plain G._wedges tshort;
   Member_plain G._keys tshort; Member_plain G._flags tshort;
   Member_plain G._timer tushort].
Definition transition_warp_members : members :=
  [Member_plain G._type tuchar; Member_plain G._levelNum tuchar;
   Member_plain G._areaIdx tuchar; Member_plain G._nodeId tuchar;
   Member_plain G._arg tuint].

Lemma generated_transition_hud_definition :
  In (Composite G._HudDisplay Struct transition_hud_members noattr)
    (prog_types G.prog).
Proof. vm_compute. repeat first [left; reflexivity | right]. Qed.

Lemma generated_transition_warp_definition :
  In (Composite G._WarpDest Struct transition_warp_members noattr)
    (prog_types G.prog).
Proof. vm_compute. repeat first [left; reflexivity | right]. Qed.

Lemma generated_demo_transition_layout_exists :
  forall ge, genv_cenv ge = prog_comp_env G.prog ->
    exists layout : demo_transition_layout ge, True.
Proof.
  intros ge Hce.
  destruct (build_composite_env_charact G._HudDisplay Struct
    transition_hud_members noattr (prog_types G.prog) (prog_comp_env G.prog)
    (prog_comp_env_eq G.prog) generated_transition_hud_definition)
    as (hud_co & Hhud & Hhm & Hha & Hhs).
  destruct (build_composite_env_charact G._WarpDest Struct
    transition_warp_members noattr (prog_types G.prog) (prog_comp_env G.prog)
    (prog_comp_env_eq G.prog) generated_transition_warp_definition)
    as (warp_co & Hwarp & Hwm & Hwa & Hws).
  refine (ex_intro _ {| transition_hud_composite := hud_co;
    transition_warp_composite := warp_co;
    transition_hud_lookup := _; transition_warp_lookup := _;
    transition_hud_flags := _; transition_warp_type := _ |} I).
  - rewrite Hce. exact Hhud.
  - rewrite Hce. exact Hwarp.
  - rewrite Hhm. reflexivity.
  - rewrite Hwm. reflexivity.
Qed.

Ltac game_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [game_expr | demo_reduce; reflexivity]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [game_expr | game_expr | demo_reduce; reflexivity]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [game_expr | demo_reduce; reflexivity]
  | _ => demo_expr
  end.

Ltac game_control_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      first
      [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
        [game_control_stmt | game_control_stmt]
      |eapply exec_Sseq_2;
        [game_control_stmt | discriminate]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
      [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
        [game_expr | reflexivity | game_control_stmt]
      |eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
        [game_expr | reflexivity | game_control_stmt]]
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; game_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [demo_lvalue | game_expr | demo_reduce; reflexivity |
       eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; game_expr
  end.

Lemma generated_change_level_body_identical_us_jp :
  fn_body G.f_play_mode_change_level =
  fn_body jp_level_update.f_play_mode_change_level.
Proof. reflexivity. Qed.

(** This finishes the actual transition function when the callback is null,
    the timer is zero and no ordinary warp destination is pending.  Requiring
    the real type-byte load to be zero is essential: otherwise this generated
    function returns the ordinary destination level instead. *)
Definition demo_special_transition_execution_claim : Prop :=
  forall (ge : Clight.genv) (layout : demo_transition_layout ge) le before
      update timer hud warp special code,
    Genv.find_symbol ge G._sTransitionUpdate = Some update ->
    Genv.find_symbol ge G._sTransitionTimer = Some timer ->
    Genv.find_symbol ge G._gHudDisplay = Some hud ->
    Genv.find_symbol ge G._sWarpDest = Some warp ->
    Genv.find_symbol ge G._D_80339EE0 = Some special ->
    warp <> timer -> warp <> hud -> warp <> update ->
    special <> timer -> special <> hud -> special <> update ->
    Mem.load Mptr before update 0 = Some Vzero ->
    Mem.load Mint16signed before timer 0 = Some Vzero ->
    Mem.load Mint8unsigned before warp 0 = Some Vzero ->
    Mem.load Mint16signed before special 0 = Some (Vint code) ->
    Mem.valid_access before Mint16signed timer 0 Writable ->
    Mem.valid_access before Mint16signed hud 10 Writable ->
    Mem.valid_access before Mptr update 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge empty_env le before
        (fn_body G.f_play_mode_change_level) E0 le' after
        (Out_return (Some (Vint code, tshort))) /\
      exec_stmt function_entry2 ge empty_env le before
        (fn_body jp_level_update.f_play_mode_change_level) E0 le' after
        (Out_return (Some (Vint code, tshort))) /\
      eval_funcall function_entry2 ge before
        (Internal G.f_play_mode_change_level) [] E0 after (Vint code) /\
      eval_funcall function_entry2 ge before
        (Internal jp_level_update.f_play_mode_change_level) [] E0 after
        (Vint code) /\
      (forall chunk b ofs,
        b <> timer -> b <> hud -> b <> update ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).

Theorem generated_demo_special_transition_executes_us_jp :
  demo_special_transition_execution_claim.
Proof.
  intros ge layout le before update timer hud warp special code
    Hupdate Htimer Hhud Hwarp Hspecial Hwt Hwh Hwu Hst Hsh Hsu
    Hcallback Hcount Htype Hcode Hwtimer Hwhud Hwupdate.
  destruct layout as [hud_co warp_co Hhud_co Hwarp_co Hflags Htypeoffset].
  destruct (Mem.valid_access_store before Mint16signed timer 0
    (Vint Int.mone) ltac:(demo_access)) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint16signed hud 10 Vzero
    ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint16signed timer 0 Vzero
    ltac:(demo_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mptr update 0 Vzero
    ltac:(demo_access)) as [after Hs4].
  assert (Hexec : exists le',
    exec_stmt function_entry2 ge empty_env le before
      (fn_body G.f_play_mode_change_level) E0 le' after
      (Out_return (Some (Vint code, tshort)))).
  { eexists. cbn [G.f_play_mode_change_level fn_body]. game_control_stmt. }
  assert (Hcall : eval_funcall function_entry2 ge before
    (Internal G.f_play_mode_change_level) [] E0 after (Vint code)).
  { eapply eval_funcall_internal with (e := empty_env)
      (le1 := create_undef_temps (fn_temps G.f_play_mode_change_level))
      (m1 := before) (m2 := after)
      (out := Out_return (Some (Vint code, tshort))).
    - constructor.
      + constructor.
      + constructor.
      + unfold list_disjoint. cbn. tauto.
      + constructor.
      + reflexivity.
    - cbn [G.f_play_mode_change_level fn_body]. game_control_stmt.
    - split; [discriminate | reflexivity].
    - reflexivity. }
  destruct Hexec as [le' Hexec]. exists after, le'.
  split; [exact Hexec |]. split.
  - rewrite <- generated_change_level_body_identical_us_jp. exact Hexec.
  - split; [exact Hcall |]. split; [exact Hcall |].
    intros chunk b ofs Hbt Hbh Hbu.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; congruence).
    reflexivity.
Qed.

Definition demo_gameplay_boundary_claim : Prop :=
  painting_null_memory_execution_claim /\
  nonnull_demo_delayed_dispatch_execution_claim /\
  demo_special_transition_execution_claim.

Theorem generated_demo_gameplay_boundary_us_jp :
  demo_gameplay_boundary_claim.
Proof.
  split; [exact generated_painting_null_memory_execution_us_jp |].
  split.
  - exact generated_nonnull_demo_delayed_dispatch_executes.
  - exact generated_demo_special_transition_executes_us_jp.
Qed.

(** A narrowly named semantic observation: an actual invocation of the generated
    normal gameplay update with demo and level globals loaded from its memory.
    It excludes standalone input processing during the title fade.  It does not
    assert an initialized area, authenticate the source stream, or certify the
    record consumed earlier by read_controller_inputs in this frame.  Those are
    distinct composition obligations, not smuggled into a preservation axiom. *)
Definition demo_normal_update_observation
    (ge : Clight.genv) (s : Clight.state)
    (stream : block) (record : ptrofs) (level : int) : Prop :=
  exists k m demo_global level_global,
    s = Callstate (Internal G.f_play_mode_normal) [] k m /\
    Genv.find_symbol ge G._gCurrDemoInput = Some demo_global /\
    Genv.find_symbol ge G._gCurrLevelNum = Some level_global /\
    Mem.load Mptr m demo_global 0 = Some (Vptr stream record) /\
    Mem.load Mint16signed m level_global 0 = Some (Vint level).
