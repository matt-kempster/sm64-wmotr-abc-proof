From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Floats Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update us_area jp_area.
From Demo.Proofs Require Import DemoStartExecution DemoGameplayBoundary.
Import ListNotations.
Local Open Scope Z_scope.
Module W := us_level_update.
Module A := us_area.

Lemma generated_transition_callees_identical_us_jp :
  A.f_set_warp_transition_rgb = jp_area.f_set_warp_transition_rgb /\
  A.f_play_transition = jp_area.f_play_transition.
Proof. split; reflexivity. Qed.

Definition black_rgb_temps : temp_env :=
  PTree.set A._blue Vzero
    (PTree.set A._green Vzero
      (PTree.set A._red Vzero (create_undef_temps (fn_temps A.f_set_warp_transition_rgb)))).

Theorem generated_black_rgb_call_executes :
  forall (ge : Clight.genv) before framebuffer red green blue,
    Genv.find_symbol ge A._gWarpTransFBSetColor = Some framebuffer ->
    Genv.find_symbol ge A._gWarpTransRed = Some red ->
    Genv.find_symbol ge A._gWarpTransGreen = Some green ->
    Genv.find_symbol ge A._gWarpTransBlue = Some blue ->
    Mem.valid_access before Mint32 framebuffer 0 Writable ->
    Mem.valid_access before Mint8unsigned red 0 Writable ->
    Mem.valid_access before Mint8unsigned green 0 Writable ->
    Mem.valid_access before Mint8unsigned blue 0 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal A.f_set_warp_transition_rgb)
        [Vzero; Vzero; Vzero] E0 after Vundef /\
      (forall chunk b ofs p,
        Mem.valid_access before chunk b ofs p ->
        Mem.valid_access after chunk b ofs p) /\
      (forall chunk b ofs,
        b <> framebuffer -> b <> red -> b <> green -> b <> blue ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).
Proof.
  intros ge before framebuffer red green blue Hframebuffer Hred Hgreen Hblue
    Hwf Hwr Hwg Hwb.
  destruct (Mem.valid_access_store before Mint32 framebuffer 0
    (Vint (Int.repr 65537)) ltac:(demo_access)) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint8unsigned red 0 Vzero
    ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint8unsigned green 0 Vzero
    ltac:(demo_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint8unsigned blue 0 Vzero
    ltac:(demo_access)) as [after Hs4].
  exists after. split.
  - eapply eval_funcall_internal with (e := empty_env) (le1 := black_rgb_temps)
      (m1 := before) (m2 := after) (out := Out_normal).
    + constructor.
      * constructor.
      * cbn. constructor; [vm_compute; intuition discriminate |].
        constructor; [vm_compute; intuition discriminate |].
        constructor; [cbn; tauto | constructor].
      * unfold list_disjoint. intros x y Hx Hy Heq. subst.
        vm_compute in Hx, Hy. intuition congruence.
      * constructor.
      * reflexivity.
    + cbn [A.f_set_warp_transition_rgb fn_body]. unfold black_rgb_temps.
      game_control_stmt.
    + reflexivity.
    + reflexivity.
  - split.
    + intros chunk b ofs p Haccess. demo_access.
    + intros chunk b ofs Hbf Hbr Hbg Hbb.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by (left; congruence).
    reflexivity.
Qed.

Definition demo_transition_members : members :=
  [Member_plain A._isActive tuchar; Member_plain A._type tuchar;
   Member_plain A._time tuchar; Member_plain A._pauseRendering tuchar;
   Member_plain A._data (Tstruct A._WarpTransitionData noattr)].
Definition demo_transition_data_members : members :=
  [Member_plain A._red tuchar; Member_plain A._green tuchar;
   Member_plain A._blue tuchar; Member_plain A._startTexRadius tshort;
   Member_plain A._endTexRadius tshort; Member_plain A._startTexX tshort;
   Member_plain A._startTexY tshort; Member_plain A._endTexX tshort;
   Member_plain A._endTexY tshort; Member_plain A._texTimer tshort].

Record demo_transition_store_layout (ge : Clight.genv) : Type := {
  demo_transition_co : composite;
  demo_transition_data_co : composite;
  demo_transition_co_lookup : (genv_cenv ge) ! A._WarpTransition =
    Some demo_transition_co;
  demo_transition_data_co_lookup : (genv_cenv ge) ! A._WarpTransitionData =
    Some demo_transition_data_co;
  demo_transition_co_members : co_members demo_transition_co = demo_transition_members;
  demo_transition_data_co_members : co_members demo_transition_data_co =
    demo_transition_data_members;
  demo_transition_data_co_align : co_alignof demo_transition_data_co = 2
}.

Lemma generated_transition_definition :
  In (Composite A._WarpTransition Struct demo_transition_members noattr)
    (prog_types A.prog).
Proof. vm_compute. repeat first [left; reflexivity | right]. Qed.

Lemma generated_transition_data_definition :
  In (Composite A._WarpTransitionData Struct demo_transition_data_members noattr)
    (prog_types A.prog).
Proof. vm_compute. repeat first [left; reflexivity | right]. Qed.

Lemma generated_transition_store_layout_exists :
  forall ge, genv_cenv ge = prog_comp_env A.prog ->
    exists layout : demo_transition_store_layout ge, True.
Proof.
  intros ge Hce.
  destruct (build_composite_env_charact A._WarpTransition Struct
    demo_transition_members noattr (prog_types A.prog) (prog_comp_env A.prog)
    (prog_comp_env_eq A.prog) generated_transition_definition)
    as (transition_co & Htransition & Htm & Hta & Hts).
  destruct (build_composite_env_charact A._WarpTransitionData Struct
    demo_transition_data_members noattr (prog_types A.prog) (prog_comp_env A.prog)
    (prog_comp_env_eq A.prog) generated_transition_data_definition)
    as (data_co & Hdata & Hdm & Hda & Hds).
  pose proof (build_composite_env_consistent _ _ (prog_comp_env_eq A.prog)
    _ _ Hdata) as Hconsistent.
  destruct Hconsistent as [Hcomplete Halign Hsize Hrank].
  assert (Htwo : co_alignof data_co = 2).
  { rewrite Halign, Hdm, Hda. reflexivity. }
  refine (ex_intro _ {| demo_transition_co := transition_co;
    demo_transition_data_co := data_co;
    demo_transition_co_lookup := _; demo_transition_data_co_lookup := _;
    demo_transition_co_members := Htm; demo_transition_data_co_members := Hdm;
    demo_transition_data_co_align := Htwo |} I).
  - rewrite Hce. exact Htransition.
  - rewrite Hce. exact Hdata.
Qed.

Lemma demo_aspect_quotient_bits :
  Float32.div (Float32.of_bits (Int.repr 1082130432))
    (Float32.of_bits (Int.repr 1077936128)) =
  Float32.of_bits (Int.repr 1068149419).
Proof.
  rewrite <- (Float32.of_to_bits
    (Float32.div (Float32.of_bits (Int.repr 1082130432))
      (Float32.of_bits (Int.repr 1077936128)))).
  f_equal; vm_compute; reflexivity.
Qed.

Lemma demo_aspect_radius_bits :
  Float32.mul (Float32.of_int (Int.repr 240))
    (Float32.of_bits (Int.repr 1068149419)) =
  Float32.of_bits (Int.repr 1134559232).
Proof.
  rewrite <- (Float32.of_to_bits
    (Float32.mul (Float32.of_int (Int.repr 240))
      (Float32.of_bits (Int.repr 1068149419)))).
  f_equal; vm_compute; reflexivity.
Qed.

Ltac scheduling_reduce :=
  cbn [cast_int_single];
  try rewrite demo_aspect_quotient_bits;
  try rewrite demo_aspect_radius_bits;
  first [reflexivity | vm_compute; reflexivity].

Ltac scheduling_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Econst_single _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn [set_opttemp];
      repeat rewrite PTree.gsspec; cbn; first [reflexivity | eassumption]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [scheduling_expr | scheduling_expr | scheduling_reduce]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [scheduling_expr | scheduling_reduce]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [scheduling_expr | scheduling_reduce]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue;
      [scheduling_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; demo_load]
             |eapply deref_loc_reference; reflexivity
             |eapply deref_loc_copy; reflexivity]]
  end
with scheduling_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ =>
      eapply eval_Ederef; scheduling_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct;
      [scheduling_expr | reflexivity | eassumption |
       first [eassumption |
         match goal with H : co_members ?co = _ |- context [co_members ?co] =>
           rewrite H; reflexivity end]]
  end.

Ltac scheduling_arguments :=
  first [constructor |
    eapply eval_Econs; [scheduling_expr | scheduling_reduce | scheduling_arguments]].

Ltac scheduling_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      first
      [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
        [scheduling_stmt | scheduling_stmt]
      |eapply exec_Sseq_2; [scheduling_stmt | discriminate]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
      [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
        [scheduling_expr | reflexivity | scheduling_stmt]
      |eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
        [scheduling_expr | reflexivity | scheduling_stmt]]
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; scheduling_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [first [scheduling_lvalue | match goal with |- ?g => idtac "SCHED LVALUE" g end; fail 1000] |
       first [scheduling_expr | match goal with |- ?g => idtac "SCHED EXPR" g end; fail 1000] |
       first [scheduling_reduce | match goal with |- ?g => idtac "SCHED CAST" g end; fail 1000] |
       eapply assign_loc_value; [reflexivity |
         try unfold bitalignof; cbn [alignof]; demo_reduce;
         repeat match goal with
         | H : co_alignof ?co = _ |- context [co_alignof ?co] => rewrite H
         end; cbn;
         first [eassumption | match goal with |- ?g => idtac "SCHED STORE" g end; fail 1000]]]
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity |
       first [scheduling_expr | match goal with |- ?g => idtac "SCHED CALL EXP" g end; fail 1000] |
       scheduling_arguments |
       first [cbn; eassumption | match goal with |- ?g => idtac "SCHED CALL TARGET" g end; fail 1000] |
       reflexivity |
       first [eassumption | match goal with |- ?g => idtac "SCHED CALL BODY" g end; fail 1000]]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; scheduling_expr
  | |- exec_stmt _ _ _ _ _ Sbreak _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ =>
      eapply exec_Sswitch with (v := Vint (Int.repr 22)) (n := 22)
        (out := Out_break);
      [first [scheduling_expr | match goal with |- ?g => idtac "SWITCH EXP" g end; fail 1000] |
       first [reflexivity | match goal with |- ?g => idtac "SWITCH VAL" g end; fail 1000] |
       lazymatch goal with
       | |- exec_stmt ?entry ?ge ?e ?le ?m ?body ?trace ?le' ?m' ?out =>
         let reduced := eval vm_compute in body in
         change (exec_stmt entry ge e le m reduced trace le' m' out)
       end;
       scheduling_stmt]
  end.

Lemma transition_access_from_range :
  forall m b chunk ofs,
    0 <= ofs -> ofs + size_chunk chunk <= 22 ->
    (align_chunk chunk | ofs) ->
    Mem.range_perm m b 0 22 Cur Writable ->
    Mem.valid_access m chunk b ofs Writable.
Proof.
  intros m b chunk ofs Hlo Hhi Halign Hrange. split; [| exact Halign].
  intros index Hindex. apply Hrange. lia.
Qed.

Ltac transition_access :=
  first [eassumption |
    lazymatch goal with
    | |- Mem.valid_access ?m _ _ _ _ =>
      first
      [match goal with
       | H : Mem.store _ _ _ _ _ = Some m |- _ =>
           eapply Mem.store_valid_access_1; [exact H | transition_access]
       end
      |match goal with
       | H : forall chunk b ofs p,
           Mem.valid_access ?before chunk b ofs p ->
           Mem.valid_access m chunk b ofs p |- _ =>
             apply H; transition_access
       end
      |eapply transition_access_from_range;
        [cbn; lia | cbn; lia |
         lazymatch goal with |- (align_chunk ?chunk | ?ofs) =>
           let witness := eval vm_compute in (ofs / align_chunk chunk) in
           exists witness; reflexivity end
        |eassumption]]
    end].

Definition demo_transition_entry_temps : temp_env :=
  PTree.set A._blue Vzero
    (PTree.set A._green Vzero
      (PTree.set A._red Vzero
        (PTree.set A._time (Vint (Int.repr 20))
          (PTree.set A._transType (Vint (Int.repr 9))
            (create_undef_temps (fn_temps A.f_play_transition)))))).

Theorem generated_demo_transition_call_executes :
  forall (ge : Clight.genv) (layout : demo_transition_store_layout ge)
      before transition framebuffer red green blue rgb_function,
    Genv.find_symbol ge A._gWarpTransition = Some transition ->
    Genv.find_symbol ge A._gWarpTransFBSetColor = Some framebuffer ->
    Genv.find_symbol ge A._gWarpTransRed = Some red ->
    Genv.find_symbol ge A._gWarpTransGreen = Some green ->
    Genv.find_symbol ge A._gWarpTransBlue = Some blue ->
    Genv.find_symbol ge A._set_warp_transition_rgb = Some rgb_function ->
    Genv.find_funct_ptr ge rgb_function = Some (Internal A.f_set_warp_transition_rgb) ->
    Mem.range_perm before transition 0 22 Cur Writable ->
    Mem.valid_access before Mint32 framebuffer 0 Writable ->
    Mem.valid_access before Mint8unsigned red 0 Writable ->
    Mem.valid_access before Mint8unsigned green 0 Writable ->
    Mem.valid_access before Mint8unsigned blue 0 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal A.f_play_transition)
        [Vint (Int.repr 9); Vint (Int.repr 20); Vzero; Vzero; Vzero] E0 after Vundef /\
      (forall chunk b ofs p,
        Mem.valid_access before chunk b ofs p ->
        Mem.valid_access after chunk b ofs p) /\
      (forall chunk b ofs,
        b <> transition -> b <> framebuffer -> b <> red -> b <> green -> b <> blue ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).
Proof.
  intros ge layout before transition framebuffer red green blue rgb_function
    Htransition Hframebuffer Hred Hgreen Hblue Hrgb_function Hrgb_body
    Hrange Hwf Hwr Hwg Hwb.
  destruct layout as [transition_co data_co Hco Hdata_co Hmembers Hdata_members Halign].
  destruct (Mem.valid_access_store before Mint8unsigned transition 0
    (Vint Int.one) ltac:(transition_access)) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint8unsigned transition 1
    (Vint (Int.repr 9)) ltac:(transition_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint8unsigned transition 2
    (Vint (Int.repr 20)) ltac:(transition_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint8unsigned transition 3
    Vzero ltac:(transition_access)) as [m4 Hs4].
  destruct (generated_black_rgb_call_executes ge m4 framebuffer red green blue
    Hframebuffer Hred Hgreen Hblue ltac:(demo_access) ltac:(demo_access)
    ltac:(demo_access) ltac:(demo_access)) as [m5 [Hrgb [Hrgb_access Hrgb_frame]]].
  destruct (Mem.valid_access_store m5 Mint8unsigned transition 4
    Vzero ltac:(transition_access)) as [m6 Hs6].
  destruct (Mem.valid_access_store m6 Mint8unsigned transition 5
    Vzero ltac:(transition_access)) as [m7 Hs7].
  destruct (Mem.valid_access_store m7 Mint8unsigned transition 6
    Vzero ltac:(transition_access)) as [m8 Hs8].
  destruct (Mem.valid_access_store m8 Mint16signed transition 12
    (Vint (Int.repr 160)) ltac:(transition_access)) as [m9 Hs9].
  destruct (Mem.valid_access_store m9 Mint16signed transition 14
    (Vint (Int.repr 120)) ltac:(transition_access)) as [m10 Hs10].
  destruct (Mem.valid_access_store m10 Mint16signed transition 16
    (Vint (Int.repr 160)) ltac:(transition_access)) as [m11 Hs11].
  destruct (Mem.valid_access_store m11 Mint16signed transition 18
    (Vint (Int.repr 120)) ltac:(transition_access)) as [m12 Hs12].
  destruct (Mem.valid_access_store m12 Mint16signed transition 20
    Vzero ltac:(transition_access)) as [m13 Hs13].
  destruct (Mem.valid_access_store m13 Mint16signed transition 8
    (Vint (Int.repr 320)) ltac:(transition_access)) as [m14 Hs14].
  destruct (Mem.valid_access_store m14 Mint16signed transition 10
    Vzero ltac:(transition_access)) as [after Hs15].
  exists after. split.
  - eapply eval_funcall_internal with (e := empty_env)
      (le1 := demo_transition_entry_temps) (m1 := before) (m2 := after)
      (out := Out_normal).
    + constructor.
      * constructor.
      * cbn. constructor; [vm_compute; intuition discriminate |].
        constructor; [vm_compute; intuition discriminate |].
        constructor; [vm_compute; intuition discriminate |].
        constructor; [vm_compute; intuition discriminate |].
        constructor; [cbn; tauto | constructor].
      * unfold list_disjoint. intros x y Hx Hy Heq. subst.
        vm_compute in Hx, Hy. intuition congruence.
      * constructor.
      * reflexivity.
    + cbn [A.f_play_transition fn_body]. unfold demo_transition_entry_temps.
      scheduling_stmt.
    + reflexivity.
    + reflexivity.
  - split.
    + intros chunk b ofs p Haccess.
      do 10 (eapply Mem.store_valid_access_1; [eassumption |]).
      apply Hrgb_access. demo_access.
    + intros chunk b ofs Hbt Hbf Hbr Hbg Hbb.
    repeat match goal with
    | H : Mem.store _ ?before _ _ _ = Some ?after |-
        context [Mem.load ?chunk ?after ?b ?ofs] =>
          rewrite (Mem.load_store_other _ _ _ _ _ _ H) by (left; congruence)
    end.
    rewrite Hrgb_frame by assumption.
    repeat match goal with
    | H : Mem.store _ ?before _ _ _ = Some ?after |-
        context [Mem.load ?chunk ?after ?b ?ofs] =>
          rewrite (Mem.load_store_other _ _ _ _ _ _ H) by (left; congruence)
    end. reflexivity.
Qed.

Lemma stores_preserve_range_permissions :
  forall chunk before store_block store_offset value after b lo hi k p,
    Mem.store chunk before store_block store_offset value = Some after ->
    Mem.range_perm before b lo hi k p -> Mem.range_perm after b lo hi k p.
Proof.
  intros chunk before store_block store_offset value after b lo hi k p Hstore Hrange.
  intros index Hindex. eapply Mem.perm_store_1; [exact Hstore |].
  apply Hrange. exact Hindex.
Qed.

Ltac scheduling_range :=
  first [assumption |
    lazymatch goal with
    | |- Mem.range_perm ?m _ _ _ _ _ =>
      match goal with H : Mem.store _ _ _ _ _ = Some m |- _ =>
        eapply stores_preserve_range_permissions; [exact H | scheduling_range]
      end
    end].

Definition demo_next_entry_temps (mario : block) : temp_env :=
  PTree.set W._warpOp (Vint (Int.repr 22))
    (PTree.set W._m (Vptr mario Ptrofs.zero)
      (create_undef_temps (fn_temps W.f_level_trigger_warp))).

Definition demo_start_scheduling_execution_claim : Prop :=
  forall (ge : Clight.genv) (layout : demo_transition_store_layout ge)
      before mario mario_co argument operation timer source saved
      transition framebuffer red green blue rgb_function transition_function,
    (genv_cenv ge) ! W._MarioState = Some mario_co ->
    field_offset (genv_cenv ge) W._invincTimer (co_members mario_co) = OK (38, Full) ->
    Genv.find_symbol ge W._sDelayedWarpArg = Some argument ->
    Genv.find_symbol ge W._sDelayedWarpOp = Some operation ->
    Genv.find_symbol ge W._sDelayedWarpTimer = Some timer ->
    Genv.find_symbol ge W._sSourceWarpNodeId = Some source ->
    Genv.find_symbol ge W._gSavedCourseNum = Some saved ->
    Genv.find_symbol ge A._gWarpTransition = Some transition ->
    Genv.find_symbol ge A._gWarpTransFBSetColor = Some framebuffer ->
    Genv.find_symbol ge A._gWarpTransRed = Some red ->
    Genv.find_symbol ge A._gWarpTransGreen = Some green ->
    Genv.find_symbol ge A._gWarpTransBlue = Some blue ->
    Genv.find_symbol ge A._set_warp_transition_rgb = Some rgb_function ->
    Genv.find_funct_ptr ge rgb_function = Some (Internal A.f_set_warp_transition_rgb) ->
    Genv.find_symbol ge W._play_transition = Some transition_function ->
    Genv.find_funct_ptr ge transition_function = Some (Internal A.f_play_transition) ->
    (forall b, In b [timer; source; saved; transition; framebuffer; red; green; blue] ->
      operation <> b) ->
    (forall b, In b [source; saved; transition; framebuffer; red; green; blue] ->
      timer <> b) ->
    Mem.load Mint16signed before operation 0 = Some Vzero ->
    Mem.valid_access before Mint16signed mario 38 Writable ->
    Mem.valid_access before Mint32 argument 0 Writable ->
    Mem.valid_access before Mint16signed operation 0 Writable ->
    Mem.valid_access before Mint16signed timer 0 Writable ->
    Mem.valid_access before Mint16signed source 0 Writable ->
    Mem.valid_access before Mint16signed saved 0 Writable ->
    Mem.range_perm before transition 0 22 Cur Writable ->
    Mem.valid_access before Mint32 framebuffer 0 Writable ->
    Mem.valid_access before Mint8unsigned red 0 Writable ->
    Mem.valid_access before Mint8unsigned green 0 Writable ->
    Mem.valid_access before Mint8unsigned blue 0 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal W.f_level_trigger_warp)
        [Vptr mario Ptrofs.zero; Vint (Int.repr 22)] E0 after
        (Vint (Int.repr 20)) /\
      eval_funcall function_entry2 ge before (Internal jp_level_update.f_level_trigger_warp)
        [Vptr mario Ptrofs.zero; Vint (Int.repr 22)] E0 after
        (Vint (Int.repr 20)) /\
      Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
      Mem.load Mint16signed after timer 0 = Some (Vint (Int.repr 20)) /\
      (forall chunk b ofs p,
        Mem.valid_access before chunk b ofs p ->
        Mem.valid_access after chunk b ofs p) /\
      (forall chunk b ofs,
        ~ In b [mario; argument; operation; timer; source; saved;
                 transition; framebuffer; red; green; blue] ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).

Theorem generated_demo_next_is_really_scheduled_us_jp :
  demo_start_scheduling_execution_claim.
Proof.
  intros ge layout before mario mario_co argument operation timer source saved
    transition framebuffer red green blue rgb_function transition_function
    Hmario_co Hinvinc Hargument Hoperation Htimer Hsource Hsaved Htransition
    Hframebuffer Hred Hgreen Hblue Hrgb_function Hrgb_body
    Htransition_function Htransition_body Hopsep Htimersep Hnone
    Hwmario Hwargument Hwoperation Hwtimer Hwsource Hwsaved Hrange Hwf Hwr Hwg Hwb.
  assert (Hots : operation <> timer) by (apply Hopsep; cbn; tauto).
  assert (Hoss : operation <> source) by (apply Hopsep; cbn; tauto).
  assert (Hosc : operation <> saved) by (apply Hopsep; cbn; tauto).
  assert (Hot : operation <> transition) by (apply Hopsep; cbn; tauto).
  assert (Hof : operation <> framebuffer) by (apply Hopsep; cbn; tauto).
  assert (Hor : operation <> red) by (apply Hopsep; cbn; tauto).
  assert (Hog : operation <> green) by (apply Hopsep; cbn; tauto).
  assert (Hob : operation <> blue) by (apply Hopsep; cbn; tauto).
  assert (Hts : timer <> source) by (apply Htimersep; cbn; tauto).
  assert (Htc : timer <> saved) by (apply Htimersep; cbn; tauto).
  assert (Htt : timer <> transition) by (apply Htimersep; cbn; tauto).
  assert (Htf : timer <> framebuffer) by (apply Htimersep; cbn; tauto).
  assert (Htr : timer <> red) by (apply Htimersep; cbn; tauto).
  assert (Htg : timer <> green) by (apply Htimersep; cbn; tauto).
  assert (Htb : timer <> blue) by (apply Htimersep; cbn; tauto).
  destruct (Mem.valid_access_store before Mint16signed mario 38
    (Vint Int.mone) ltac:(demo_access)) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint32 argument 0
    Vzero ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint16signed operation 0
    (Vint (Int.repr 22)) ltac:(demo_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint16signed timer 0
    (Vint (Int.repr 20)) ltac:(demo_access)) as [m4 Hs4].
  destruct (Mem.valid_access_store m4 Mint16signed source 0
    (Vint (Int.repr 240)) ltac:(demo_access)) as [m5 Hs5].
  destruct (Mem.valid_access_store m5 Mint16signed saved 0
    Vzero ltac:(demo_access)) as [m6 Hs6].
  destruct (generated_demo_transition_call_executes ge layout m6 transition
    framebuffer red green blue rgb_function
    Htransition Hframebuffer Hred Hgreen Hblue Hrgb_function Hrgb_body
    ltac:(scheduling_range) ltac:(demo_access) ltac:(demo_access)
    ltac:(demo_access) ltac:(demo_access))
    as [after [Htransition_call [Htransition_access Htransition_frame]]].
  assert (Htimer_after : Mem.load Mint16signed after timer 0 =
    Some (Vint (Int.repr 20))).
  { rewrite Htransition_frame by assumption. demo_load. }
  assert (Hop_after : Mem.load Mint16signed after operation 0 =
    Some (Vint (Int.repr 22))).
  { rewrite Htransition_frame by assumption. demo_load. }
  assert (Hus : eval_funcall function_entry2 ge before (Internal W.f_level_trigger_warp)
    [Vptr mario Ptrofs.zero; Vint (Int.repr 22)] E0 after (Vint (Int.repr 20))).
  { eapply eval_funcall_internal with (e := empty_env)
      (le1 := demo_next_entry_temps mario) (m1 := before) (m2 := after)
      (out := Out_return (Some (Vint (Int.repr 20), tshort))).
    - constructor.
      + constructor.
      + cbn. constructor; [vm_compute; intuition discriminate |].
        constructor; [cbn; tauto | constructor].
      + unfold list_disjoint. intros x y Hx Hy Heq. subst.
        vm_compute in Hx, Hy. intuition congruence.
      + constructor.
      + reflexivity.
    - cbn [W.f_level_trigger_warp fn_body]. unfold demo_next_entry_temps.
      scheduling_stmt.
    - split; [discriminate | reflexivity].
    - reflexivity. }
  assert (Hjp : eval_funcall function_entry2 ge before
    (Internal jp_level_update.f_level_trigger_warp)
    [Vptr mario Ptrofs.zero; Vint (Int.repr 22)] E0 after (Vint (Int.repr 20))).
  { eapply eval_funcall_internal with (e := empty_env)
      (le1 := demo_next_entry_temps mario) (m1 := before) (m2 := after)
      (out := Out_return (Some (Vint (Int.repr 20), tshort))).
    - constructor.
      + constructor.
      + cbn. constructor; [vm_compute; intuition discriminate |].
        constructor; [cbn; tauto | constructor].
      + unfold list_disjoint. intros x y Hx Hy Heq. subst.
        vm_compute in Hx, Hy. intuition congruence.
      + constructor.
      + reflexivity.
    - cbn [jp_level_update.f_level_trigger_warp fn_body]. unfold demo_next_entry_temps.
      scheduling_stmt.
    - split; [discriminate | reflexivity].
    - reflexivity. }
  exists after. split; [exact Hus |]. split; [exact Hjp |].
  split; [exact Hop_after |]. split; [exact Htimer_after |]. split.
  - intros chunk b ofs p Haccess. apply Htransition_access. demo_access.
  - intros chunk b ofs Houtside.
    rewrite Htransition_frame by (cbn in Houtside; intuition congruence).
    repeat match goal with
    | H : Mem.store _ ?before ?store _ _ = Some ?after |-
        context [Mem.load ?chunk ?after ?b ?ofs] =>
          rewrite (Mem.load_store_other _ _ _ _ _ _ H) by
            (left; cbn in Houtside; intuition congruence)
    end. reflexivity.
Qed.
