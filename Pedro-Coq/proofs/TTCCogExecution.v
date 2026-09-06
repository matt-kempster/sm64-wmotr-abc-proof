From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Floats Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import
  us_obj_behaviors_2 jp_obj_behaviors_2 us_behavior_script jp_behavior_script.
From Pedro.Proofs Require Import
  GameTypes TTCCogGeometry TTCCogApproachExecution TTCCogRNG TTCCogRNGExecution.

Import ListNotations.
Open Scope Z_scope.
Module U := us_obj_behaviors_2.
Module J := jp_obj_behaviors_2.
Module B := us_behavior_script.

Definition cog_update_function (version : GameVersion) : function :=
  match version with VersionUS => U.f_bhv_ttc_cog_update
                   | VersionJP => J.f_bhv_ttc_cog_update end.
Definition cog_raw_union (version : GameVersion) : ident :=
  match version with VersionUS => U.__764 | VersionJP => J.__727 end.

Lemma cog_find_funct_zero :
  forall (ge : Clight.genv) b f,
    Genv.find_funct_ptr ge b = Some f ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some f.
Proof.
  intros ge b f Hfunction. unfold Genv.find_funct.
  destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero); [exact Hfunction | contradiction].
Qed.

(** Only the concrete cells touched by this execution are required writable.
    Function/global binding and layout are separate generated-compatible genv
    premises below. This image is not asserted to be retail-reachable. *)
Definition cog_zero_memory_image (m : mem)
    (current mode seed object : block) : Prop :=
  Mem.load Mptr m current 0 = Some (Vptr object Ptrofs.zero) /\
  Mem.load Mint16signed m mode 0 = Some (Vint (Int.repr 2)) /\
  Mem.load Mint16unsigned m seed 0 = Some (Vint (Int.repr 16)) /\
  Mem.load Mfloat32 m object 244 = Some (Vsingle (Float32.of_int Int.one)) /\
  Mem.load Mfloat32 m object 248 = Some (Vsingle Float32.zero) /\
  Mem.load Mfloat32 m object 252 = Some (Vsingle Float32.zero) /\
  Mem.load Mint32 m object 212 = Some (Vint (Int.repr 57344)) /\
  Mem.valid_access m Mint16unsigned seed 0 Writable /\
  Mem.valid_access m Mfloat32 object 248 Writable /\
  Mem.valid_access m Mfloat32 object 252 Writable /\
  Mem.valid_access m Mint32 object 280 Writable /\
  Mem.valid_access m Mint32 object 212 Writable.

Ltac cog_memory_access :=
  first [assumption |
    lazymatch goal with
    | |- Mem.valid_access ?m _ _ _ _ =>
      match goal with
      | H : Mem.store _ _ _ _ _ = Some m |- _ =>
        eapply Mem.store_valid_access_1; [exact H | cog_memory_access]
      end
    end].

Ltac cog_memory_load :=
  lazymatch goal with
  | |- Mem.load ?chunk ?m ?b ?ofs = ?value =>
      let offset := eval vm_compute in ofs in
      change (Mem.load chunk m b offset = value)
  end;
  first [eassumption |
    lazymatch goal with
    | |- Mem.load _ ?m _ _ = _ =>
      match goal with
      | H : Mem.store _ _ _ _ _ = Some m |- _ =>
        first
          [rewrite (Mem.load_store_same _ _ _ _ _ _ H); cbn; reflexivity
          |rewrite (Mem.load_store_other _ _ _ _ _ _ H);
           [cog_memory_load |
            first [left; congruence | right; left; cbn; lia |
                   right; right; cbn; lia]]]
      end
    end].

Ltac cog_memory_store := eassumption.

Ltac cog_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Econst_single _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn; reflexivity
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [cog_expr | cog_expr | cbn; reflexivity]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [cog_expr | cbn; reflexivity]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [cog_expr | cbn; reflexivity]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue;
      [cog_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; cog_memory_load]
             |eapply deref_loc_reference; reflexivity
             |eapply deref_loc_copy; reflexivity]]
  end
with cog_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ =>
      eapply eval_Ederef; cog_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      first
        [eapply eval_Efield_struct;
         [cog_expr | reflexivity | eassumption | eassumption]
        |eapply eval_Efield_union;
         [cog_expr | reflexivity | eassumption | eassumption]]
  end.

Ltac cog_arguments :=
  first [apply eval_Enil |
    eapply eval_Econs; [cog_expr | cbn; reflexivity | cog_arguments]].

Ltac cog_norepet :=
  lazymatch goal with
  | |- Coqlib.list_norepet [] => apply Coqlib.list_norepet_nil
  | |- Coqlib.list_norepet (_ :: _) =>
      apply Coqlib.list_norepet_cons;
      [vm_compute; intuition discriminate | cog_norepet]
  end.

Ltac cog_reduce_statement :=
  lazymatch goal with
  | |- exec_stmt ?entry ?ge ?e ?le ?m ?s ?t ?le' ?m' ?out =>
      let reduced := eval vm_compute in s in
      change (exec_stmt entry ge e le m reduced t le' m' out)
  end.

Ltac cog_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ Sbreak _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      first
        [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
         [cog_stmt | cog_stmt]
        |eapply exec_Sseq_2; [cog_stmt | discriminate]]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
      eapply exec_Sset; cog_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [cog_lvalue | cog_expr | cbn; reflexivity |
       eapply assign_loc_value; [reflexivity | cbn; cog_memory_store]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [cog_expr | cbn; reflexivity | cog_reduce_statement; cog_stmt]
  | |- exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ =>
      eapply exec_Sswitch with (out := Out_break) (n := 2);
      [cog_expr | cbn; reflexivity |
       cog_reduce_statement; cog_stmt]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; cog_expr
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | cog_expr | cog_arguments |
       eapply cog_find_funct_zero; eassumption |
       reflexivity | cog_funcall]
  end
with cog_funcall :=
  first
  [solve [eapply generated_cog_approach_zero_with_stores;
          [cog_memory_load | eassumption | eassumption]]
  |solve [eapply generated_random_u16_cog_first_draw;
          [eassumption | cog_memory_load | eassumption | eassumption]]
  |solve [eapply generated_random_u16_cog_second_draw;
          [eassumption | cog_memory_load | eassumption | eassumption]]
  |eapply eval_funcall_internal;
  [eapply function_entry2_intro;
   [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
    vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence |
    cbn; apply alloc_variables_nil | cbn; reflexivity]
  |simpl fn_body; cog_stmt
  |cbn; first [reflexivity | split; [discriminate | reflexivity]]
  |cbn; reflexivity]].

Definition cog_zero_update_execution_claim (version : GameVersion) : Prop :=
  forall (ge : Clight.genv) before current mode seed object
      approach_code random_code sign_code object_co raw_co,
    Genv.find_symbol ge U._gCurrentObject = Some current ->
    Genv.find_symbol ge U._gTTCSpeedSetting = Some mode ->
    Genv.find_symbol ge B._gRandomSeed16 = Some seed ->
    Genv.find_symbol ge U._approach_f32_ptr = Some approach_code ->
    Genv.find_symbol ge U._random_u16 = Some random_code ->
    Genv.find_symbol ge U._random_sign = Some sign_code ->
    Genv.find_funct_ptr ge approach_code = Some (Internal U.f_approach_f32_ptr) ->
    Genv.find_funct_ptr ge random_code = Some (Internal B.f_random_u16) ->
    Genv.find_funct_ptr ge sign_code = Some (Internal B.f_random_sign) ->
    (genv_cenv ge) ! U._Object = Some object_co ->
    field_offset (genv_cenv ge) U._rawData (co_members object_co) =
      OK (136, Full) ->
    (genv_cenv ge) ! (cog_raw_union version) = Some raw_co ->
    union_field_offset (genv_cenv ge) U._asF32 (co_members raw_co) =
      OK (0, Full) ->
    union_field_offset (genv_cenv ge) U._asS32 (co_members raw_co) =
      OK (0, Full) ->
    object <> seed -> current <> object -> current <> seed ->
    mode <> object -> mode <> seed ->
    cog_zero_memory_image before current mode seed object ->
    exists after,
      eval_funcall function_entry2 ge before
        (Internal (cog_update_function version)) [] E0 after Vundef /\
      Mem.load Mint32 after object 212 = Some (Vint (Int.repr 57344)) /\
      Mem.load Mint32 after object 280 = Some (Vint Int.zero) /\
      Mem.load Mfloat32 after object 248 = Some (Vsingle Float32.zero) /\
      Mem.load Mfloat32 after object 252 = Some (Vsingle Float32.zero) /\
      Mem.load Mint16unsigned after seed 0 = Some (Vint (Int.repr 54874)).

(** Complete generated cog update, including the real approach helper,
    random_u16, random_sign and its nested random_u16. All calls are internal
    Clight executions, with no assumed callee execution or external RNG oracle.
    The concrete starting memory and generated-compatible genv are premises;
    neither a retail entry nor the following frame is asserted. *)
Theorem generated_cog_zero_update_executes_us_jp :
  forall version, cog_zero_update_execution_claim version.
Proof.
  intros version ge before current mode seed object approach_code random_code
    sign_code object_co raw_co Hcurrent Hmode Hseed Happroach Hrandom Hsign
    Happroach_code Hrandom_code Hsign_code Hobject_co Hraw_offset Hraw_co
    Hf32_offset Hs32_offset Hobject_seed Hcurrent_object Hcurrent_seed
    Hmode_object Hmode_seed Hmemory.
  destruct Hmemory as [Hcurrent_load [Hmode_load [Hseed_load [Hdir_load
    [Hspeed_load [Htarget_load [Hyaw_load [Hseed_write [Hspeed_write
    [Htarget_write [Hangvel_write Hyaw_write]]]]]]]]]]].
  destruct (Mem.valid_access_store before Mfloat32 object 248 cog_fifty
    ltac:(cog_memory_access)) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mfloat32 object 248 cog_zero
    ltac:(cog_memory_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint16unsigned seed 0
    (Vint (Int.repr 4112)) ltac:(cog_memory_access)) as [m3 Hs3].
  destruct (Mem.valid_access_store m3 Mint16unsigned seed 0
    (Vint (Int.repr 59500)) ltac:(cog_memory_access)) as [m4 Hs4].
  destruct (Mem.valid_access_store m4 Mint16unsigned seed 0
    (Vint (Int.repr 27780)) ltac:(cog_memory_access)) as [m5 Hs5].
  destruct (Mem.valid_access_store m5 Mint16unsigned seed 0
    (Vint (Int.repr 54874)) ltac:(cog_memory_access)) as [m6 Hs6].
  destruct (Mem.valid_access_store m6 Mfloat32 object 252 cog_zero
    ltac:(cog_memory_access)) as [m7 Hs7].
  destruct (Mem.valid_access_store m7 Mint32 object 280 (Vint Int.zero)
    ltac:(cog_memory_access)) as [m8 Hs8].
  destruct (Mem.valid_access_store m8 Mint32 object 212
    (Vint (Int.repr 57344)) ltac:(cog_memory_access)) as [after Hs9].
  destruct version; cbn [cog_raw_union] in Hraw_co;
    exists after; split.
  - cbn [cog_update_function]. cog_funcall.
  - repeat split; cog_memory_load.
  - cbn [cog_update_function]. cog_funcall.
  - repeat split; cog_memory_load.
Qed.

(** Kept in the cog module as well as exposed through MainTheorem, so this
    concrete result can be checked independently of the older whole-TTC census.
    It remains conditional local execution plus separate geometry/arithmetic;
    it does not assert legal entry or repeated in-spot controller control. *)
Theorem checked_ttc_cog_local_mechanism_us_jp :
  ttc_cog_geometry_reduction_claim /\
  ttc_cog_rng_reduction_claim /\
  (forall version, cog_zero_update_execution_claim version).
Proof.
  exact (conj checked_ttc_cog_geometry_reduction_us_jp
    (conj checked_ttc_cog_rng_reduction_us_jp
      generated_cog_zero_update_executes_us_jp)).
Qed.
