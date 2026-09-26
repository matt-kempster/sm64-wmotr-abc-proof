(** The selected double-pound flight, through real velocity/clamp/Y stores.

    The old live case started after the velocity update and required its new
    height to satisfy the envelope.  Here the rounded result is derived from
    actual input loads, and the selected flight's bound is computed without
    that output-bound premise.  The boundary stops before the water query.
    Floor/wall handling, attack dispatch, collision reload and the gaps between
    calls are not silently treated as memory frames. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import ClightFacts GameTypes
  EyerokRank15LiveMovement EyerokRank15MovementBodyResolution
  EyerokRank15DynamicSupport EyerokRank15VSC EyerokRank15ControllerRide
  InkBackwardExecution PyramidTopPU SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

Definition rpf_velocity version :=
  match fn_body (rank15_movement_body version) with
  | Ssequence velocity _ => velocity | _ => Sskip end.
Definition rpf_clamp version :=
  match fn_body (rank15_movement_body version) with
  | Ssequence _ (Ssequence clamp _) => clamp | _ => Sskip end.
Definition rpf_tail version :=
  match fn_body (rank15_movement_body version) with
  | Ssequence _ (Ssequence _ (Ssequence _ tail)) => tail | _ => Sskip end.
Definition rpf_prefix version := Ssequence (rpf_velocity version)
  (Ssequence (rpf_clamp version) (rank15_position_update_fragment version)).

Lemma rpf_source : forall version,
  fn_body (rank15_movement_body version) =
    Ssequence (rpf_velocity version) (Ssequence (rpf_clamp version)
      (Ssequence (rank15_position_update_fragment version) (rpf_tail version))) /\
  rpf_velocity version =
    Ssequence (Sset UOH._t'16 rank15_current_object_expression)
    (Ssequence (Sset UOH._t'17 rank15_current_object_expression)
    (Ssequence (Sset UOH._t'18
      (rank15_raw_float_expression version UOH._t'17 rank15_vy_index))
      (Sassign (rank15_raw_float_expression version UOH._t'16 rank15_vy_index)
        (Ebinop Oadd (Etempvar UOH._t'18 tfloat)
          (Ebinop Oadd (Etempvar UOH._gravity tfloat)
            (Etempvar UOH._buoyancy tfloat) tfloat) tfloat)))) /\
  rpf_clamp version =
    Ssequence (Sset UOH._t'13 rank15_current_object_expression)
    (Ssequence (Sset UOH._t'14
      (rank15_raw_float_expression version UOH._t'13 rank15_vy_index))
      (Sifthenelse (Ebinop Olt (Etempvar UOH._t'14 tfloat)
        (Eunop Oneg (Econst_single (Float32.of_bits (Int.repr 1117519872))
          tfloat) tfloat) tint)
        (Ssequence (Sset UOH._t'15 rank15_current_object_expression)
          (Sassign (rank15_raw_float_expression version UOH._t'15 rank15_vy_index)
            (Eunop Oneg (Econst_single (Float32.of_bits (Int.repr 1117519872))
              tfloat) tfloat))) Sskip)).
Proof. intros []; repeat split; reflexivity. Qed.

Definition rpf_next_velocity velocity gravity :=
  Float32.add velocity (Float32.add gravity Float32.zero).
Definition rpf_velocity_locals locals object velocity :=
  PTree.set UOH._t'18 (Vsingle velocity)
    (PTree.set UOH._t'17 object (PTree.set UOH._t'16 object locals)).
Definition rpf_clamp_locals locals object velocity :=
  PTree.set UOH._t'14 (Vsingle velocity) (PTree.set UOH._t'13 object locals).
Definition rpf_final_locals locals object y velocity gravity :=
  rank15_position_update_locals
    (rpf_clamp_locals (rpf_velocity_locals locals object velocity) object
      (rpf_next_velocity velocity gravity)) object y
    (rpf_next_velocity velocity gravity).

Lemma rpf_velocity_executes :
  forall version e le m current_block object_block object_offset velocity gravity,
  let ge := Clight.globalenv (selected_clight_target version) in
  let address := rank15_raw_address object_offset (Int.repr 10) in
  e ! UOH._gCurrentObject = None ->
  Genv.find_symbol ge UOH._gCurrentObject = Some current_block ->
  Mem.load Mptr m current_block 0 = Some (Vptr object_block object_offset) ->
  le ! UOH._gravity = Some (Vsingle gravity) ->
  le ! UOH._buoyancy = Some (Vsingle Float32.zero) ->
  Mem.load Mfloat32 m object_block (Ptrofs.unsigned address) = Some (Vsingle velocity) ->
  Mem.valid_access m Mfloat32 object_block (Ptrofs.unsigned address) Writable ->
  exists after,
    Mem.store Mfloat32 m object_block (Ptrofs.unsigned address)
      (Vsingle (rpf_next_velocity velocity gravity)) = Some after /\
    ClightBigstep.Clight2.exec_stmt ge e le m (rpf_velocity version) E0
      (rpf_velocity_locals le (Vptr object_block object_offset) velocity)
      after Out_normal.
Proof.
  intros version e le m cb ob ofs velocity gravity ge address Hlocal Hsymbol
    Hcurrent Hgravity Hbuoyancy Hvelocity Hwrite.
  destruct (Mem.valid_access_store m Mfloat32 ob (Ptrofs.unsigned address)
    (Vsingle (rpf_next_velocity velocity gravity)) Hwrite) as [after Hstore].
  exists after. split; [exact Hstore|].
  rewrite (proj1 (proj2 (rpf_source version))). unfold rpf_velocity_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply rank15_current_object_read; eauto.
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply rank15_current_object_read; eauto.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply rank15_raw_float_read.
        -- apply PTree.gss.
        -- apply rank15_vy_index_evaluates.
        -- reflexivity.
        -- exact Hvelocity.
      * eapply exec_Sassign with (loc := ob) (ofs := address) (bf := Full)
          (v2 := Vsingle (rpf_next_velocity velocity gravity))
          (v := Vsingle (rpf_next_velocity velocity gravity)).
        -- eapply rank15_raw_float_lvalue.
           ++ rank15_temporary.
           ++ apply rank15_vy_index_evaluates.
           ++ reflexivity.
        -- eapply eval_Ebinop.
           ++ apply eval_Etempvar. apply PTree.gss.
           ++ eapply eval_Ebinop.
              ** apply eval_Etempvar.
                 repeat rewrite PTree.gso by discriminate. exact Hgravity.
              ** apply eval_Etempvar.
                 repeat rewrite PTree.gso by discriminate. exact Hbuoyancy.
              ** reflexivity.
           ++ reflexivity.
        -- reflexivity.
        -- eapply assign_loc_value with (chunk := Mfloat32); eauto.
Qed.

Lemma rpf_clamp_not_taken :
  forall version e le m cb ob ofs velocity,
  let ge := Clight.globalenv (selected_clight_target version) in
  e ! UOH._gCurrentObject = None ->
  Genv.find_symbol ge UOH._gCurrentObject = Some cb ->
  Mem.load Mptr m cb 0 = Some (Vptr ob ofs) ->
  Mem.load Mfloat32 m ob
    (Ptrofs.unsigned (rank15_raw_address ofs (Int.repr 10))) = Some (Vsingle velocity) ->
  Float32.cmp Clt velocity
    (Float32.neg (Float32.of_bits (Int.repr 1117519872))) = false ->
  ClightBigstep.Clight2.exec_stmt ge e le m (rpf_clamp version) E0
    (rpf_clamp_locals le (Vptr ob ofs) velocity) m Out_normal.
Proof.
  intros version e le m cb ob ofs velocity ge Hlocal Hsymbol Hcurrent Hv Hcmp.
  rewrite (proj2 (proj2 (rpf_source version))). unfold rpf_clamp_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply rank15_current_object_read; eauto.
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply rank15_raw_float_read.
      * apply PTree.gss.
      * apply rank15_vy_index_evaluates.
      * reflexivity.
      * exact Hv.
    + eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
      * eapply eval_Ebinop.
        -- apply eval_Etempvar. apply PTree.gss.
        -- eapply eval_Eunop; [constructor|reflexivity].
        -- change (Some (Val.of_bool (Float32.cmp Clt velocity
            (Float32.neg (Float32.of_bits (Int.repr 1117519872))))) =
            Some (Vint Int.zero)). rewrite Hcmp. reflexivity.
      * reflexivity.
      * constructor.
Qed.

(** Both stores are within the hand; every disjoint cell, in particular
    Mario's velocity in its separate state allocation, is framed. *)
Definition RPFPrefixedExecution : Prop :=
  forall version e le m cb ob ofs y velocity gravity,
  let ge := Clight.globalenv (selected_clight_target version) in
  let ya := Ptrofs.unsigned (rank15_raw_address ofs (Int.repr 7)) in
  let va := Ptrofs.unsigned (rank15_raw_address ofs (Int.repr 10)) in
  e ! UOH._gCurrentObject = None ->
  Genv.find_symbol ge UOH._gCurrentObject = Some cb -> cb <> ob ->
  Mem.load Mptr m cb 0 = Some (Vptr ob ofs) ->
  le ! UOH._gravity = Some (Vsingle gravity) ->
  le ! UOH._buoyancy = Some (Vsingle Float32.zero) ->
  Mem.load Mfloat32 m ob ya = Some (Vsingle y) ->
  Mem.load Mfloat32 m ob va = Some (Vsingle velocity) ->
  Mem.valid_access m Mfloat32 ob ya Writable ->
  Mem.valid_access m Mfloat32 ob va Writable -> ya + 4 <= va ->
  Float32.cmp Clt (rpf_next_velocity velocity gravity)
    (Float32.neg (Float32.of_bits (Int.repr 1117519872))) = false ->
  exists after,
    ClightBigstep.Clight2.exec_stmt ge e le m (rpf_prefix version) E0
      (rpf_final_locals le (Vptr ob ofs) y velocity gravity) after Out_normal /\
    Mem.load Mfloat32 after ob ya =
      Some (Vsingle (Float32.add y (rpf_next_velocity velocity gravity))) /\
    Mem.load Mfloat32 after ob va = Some (Vsingle (rpf_next_velocity velocity gravity)) /\
    (forall chunk rb ro,
      (rb <> ob \/ ro + size_chunk chunk <= ya \/ ya + 4 <= ro) ->
      (rb <> ob \/ ro + size_chunk chunk <= va \/ va + 4 <= ro) ->
      Mem.load chunk after rb ro = Mem.load chunk m rb ro).

Theorem rpf_prefix_executes : RPFPrefixedExecution.
Proof.
  intros version e le m cb ob ofs y velocity gravity ge ya va Hlocal Hsymbol
    Hblocks Hcurrent Hgravity Hbuoyancy Hy Hv Hywrite Hvwrite Hsep Hcmp.
  destruct (rpf_velocity_executes version e le m cb ob ofs velocity gravity
    Hlocal Hsymbol Hcurrent Hgravity Hbuoyancy Hv Hvwrite)
    as (middle & Hstorev & Hexecv).
  assert (Hcurrent' : Mem.load Mptr middle cb 0 = Some (Vptr ob ofs)).
  { rewrite <- Hcurrent. eapply Mem.load_store_other; [exact Hstorev|auto]. }
  assert (Hy' : Mem.load Mfloat32 middle ob ya = Some (Vsingle y)).
  { rewrite <- Hy. eapply Mem.load_store_other; [exact Hstorev|right; left; exact Hsep]. }
  assert (Hv' : Mem.load Mfloat32 middle ob va =
    Some (Vsingle (rpf_next_velocity velocity gravity))).
  { exact (Mem.load_store_same _ _ _ _ _ _ Hstorev). }
  assert (Hywrite' : Mem.valid_access middle Mfloat32 ob ya Writable).
  { eapply Mem.store_valid_access_1; eauto. }
  pose proof (rpf_clamp_not_taken version e
    (rpf_velocity_locals le (Vptr ob ofs) velocity) middle cb ob ofs
    (rpf_next_velocity velocity gravity) Hlocal Hsymbol Hcurrent' Hv' Hcmp) as Hexecc.
  destruct (rank15_position_fragment_executes_from_memory version e
    (rpf_clamp_locals (rpf_velocity_locals le (Vptr ob ofs) velocity)
      (Vptr ob ofs) (rpf_next_velocity velocity gravity)) middle cb ob ofs y
    (rpf_next_velocity velocity gravity) Hlocal Hsymbol Hcurrent' Hy' Hv' Hywrite')
    as (after & Hstorey & Hexecy & Haftery & Hframey).
  exists after. split.
  - unfold rpf_prefix, rpf_final_locals.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hexecv|].
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); eassumption.
  - split; [exact Haftery|]. split.
    + rewrite <- Hv'. apply Hframey. right; right; exact Hsep.
    + intros chunk rb ro Hsy Hsv. rewrite Hframey by exact Hsy.
      eapply Mem.load_store_other; [exact Hstorev|exact Hsv].
Qed.

Print Assumptions rpf_prefix_executes.

(** The branch after the real on-ground test fails.  Extracting it from the
    generated function keeps this receipt about the actual program. *)
Fixpoint rpf_else_branches s : list statement :=
  match s with
  | Sifthenelse _ yes no => no :: (rpf_else_branches yes ++ rpf_else_branches no)
  | Ssequence first second => rpf_else_branches first ++ rpf_else_branches second
  | _ => [] end.
Definition rpf_pound_body version := match version with
  | VersionUS => UEye.f_eyerok_hand_act_double_pound
  | VersionJP => JEye.f_eyerok_hand_act_double_pound end.
Definition rpf_air_branch version :=
  nth 3 (rpf_else_branches (fn_body (rpf_pound_body version))) Sskip.
Lemma rpf_air_branch_source : forall version,
  rpf_air_branch version =
    Ssequence (Sset UOH._t'12 rank15_current_object_expression)
    (Ssequence (Sset UOH._t'13
      (rank15_raw_float_expression version UOH._t'12 rank15_vy_index))
      (Sifthenelse (Ebinop Ole (Etempvar UOH._t'13 tfloat)
        (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) tint)
        (Ssequence (Sset UOH._t'14 rank15_current_object_expression)
          (Sassign (rank15_raw_float_expression version UOH._t'14
            (Econst_int (Int.repr 23) tint))
            (Eunop Oneg (Econst_single (Float32.of_bits (Int.repr 1101004800))
              tfloat) tfloat))) Sskip)).
Proof. intros []; reflexivity. Qed.

Definition RPFRisingAction : Prop :=
  forall version e le m cb ob ofs velocity,
  let ge := Clight.globalenv (selected_clight_target version) in
  e ! UOH._gCurrentObject = None ->
  Genv.find_symbol ge UOH._gCurrentObject = Some cb ->
  Mem.load Mptr m cb 0 = Some (Vptr ob ofs) ->
  Mem.load Mfloat32 m ob
    (Ptrofs.unsigned (rank15_raw_address ofs (Int.repr 10))) = Some (Vsingle velocity) ->
  Float32.cmp Cle velocity (Float32.of_bits (Int.repr 0)) = false ->
  exists after_locals,
    ClightBigstep.Clight2.exec_stmt ge e le m (rpf_air_branch version)
      E0 after_locals m Out_normal.

Lemma rpf_rising_action_does_not_relaunch : RPFRisingAction.
Proof.
  intros version e le m cb ob ofs velocity ge Hlocal Hsymbol Hcurrent Hv Hcmp.
  rewrite rpf_air_branch_source.
  eexists. eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply rank15_current_object_read; eauto.
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply rank15_raw_float_read.
      * apply PTree.gss.
      * apply rank15_vy_index_evaluates.
      * reflexivity.
      * exact Hv.
    + eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
      * eapply eval_Ebinop.
        -- apply eval_Etempvar. apply PTree.gss.
        -- constructor.
        -- change (Some (Val.of_bool (Float32.cmp Cle velocity
            (Float32.of_bits (Int.repr 0)))) = Some (Vint Int.zero)).
           rewrite Hcmp. reflexivity.
      * reflexivity.
      * constructor.
Qed.

Definition RPFFallingAction : Prop :=
  forall version e le m cb ob ofs velocity,
  let ge := Clight.globalenv (selected_clight_target version) in
  let ga := Ptrofs.unsigned (rank15_raw_address ofs (Int.repr 23)) in
  e ! UOH._gCurrentObject = None ->
  Genv.find_symbol ge UOH._gCurrentObject = Some cb ->
  Mem.load Mptr m cb 0 = Some (Vptr ob ofs) ->
  Mem.load Mfloat32 m ob
    (Ptrofs.unsigned (rank15_raw_address ofs (Int.repr 10))) = Some (Vsingle velocity) ->
  Float32.cmp Cle velocity (Float32.of_bits (Int.repr 0)) = true ->
  Mem.valid_access m Mfloat32 ob ga Writable ->
  exists after_locals after,
    ClightBigstep.Clight2.exec_stmt ge e le m (rpf_air_branch version)
      E0 after_locals after Out_normal /\
    Mem.store Mfloat32 m ob ga
      (Vsingle (Float32.neg (Float32.of_bits (Int.repr 1101004800)))) = Some after.

Lemma rpf_falling_action_installs_gravity : RPFFallingAction.
Proof.
  intros version e le m cb ob ofs velocity ge ga Hlocal Hsymbol Hcurrent Hv Hcmp Hwrite.
  destruct (Mem.valid_access_store m Mfloat32 ob ga
    (Vsingle (Float32.neg (Float32.of_bits (Int.repr 1101004800)))) Hwrite)
    as [after Hstore].
  eexists. exists after. split; [|exact Hstore].
  rewrite rpf_air_branch_source.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply rank15_current_object_read; eauto.
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply rank15_raw_float_read.
      * apply PTree.gss.
      * apply rank15_vy_index_evaluates.
      * reflexivity.
      * exact Hv.
    + eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
      * eapply eval_Ebinop.
        -- apply eval_Etempvar. apply PTree.gss.
        -- constructor.
        -- change (Some (Val.of_bool (Float32.cmp Cle velocity
            (Float32.of_bits (Int.repr 0)))) = Some (Vint Int.one)).
           rewrite Hcmp. reflexivity.
      * reflexivity.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- apply exec_Sset. eapply rank15_current_object_read; eauto.
        -- eapply exec_Sassign with (loc := ob)
            (ofs := rank15_raw_address ofs (Int.repr 23)) (bf := Full)
            (v2 := Vsingle (Float32.neg (Float32.of_bits (Int.repr 1101004800))))
            (v := Vsingle (Float32.neg (Float32.of_bits (Int.repr 1101004800)))).
           ++ eapply rank15_raw_float_lvalue.
              ** apply PTree.gss.
              ** constructor.
              ** reflexivity.
           ++ eapply eval_Eunop; [constructor|reflexivity].
           ++ reflexivity.
           ++ eapply assign_loc_value with (chunk := Mfloat32); eauto.
Qed.

(** These are the ten unclamped steps of the selected launch and descent.
    The seventh step crosses the apex; the following action switches gravity
    to -20.  Rows are input Y/velocity/gravity and output Y/velocity. *)
Definition rpf_rows : list (Z * Z * Z * Z * Z) :=
  [(-1534,100,-15,-1449,85); (-1449,85,-15,-1379,70);
   (-1379,70,-15,-1324,55); (-1324,55,-15,-1284,40);
   (-1284,40,-15,-1259,25); (-1259,25,-15,-1249,10);
   (-1249,10,-15,-1254,-5); (-1254,-5,-20,-1279,-25);
   (-1279,-25,-20,-1324,-45); (-1324,-45,-20,-1389,-65)].
Definition rpf_float z := Float32.of_int (Int.repr z).
Definition rpf_row_check row : bool :=
  let '(y,v,g,y',v') := row in
  let next := rpf_next_velocity (rpf_float v) (rpf_float g) in
  Int.eq (Float32.to_bits next) (Float32.to_bits (rpf_float v')) &&
  Int.eq (Float32.to_bits (Float32.add (rpf_float y) next))
    (Float32.to_bits (rpf_float y')) &&
  negb (Float32.cmp Clt next
    (Float32.neg (Float32.of_bits (Int.repr 1117519872)))) &&
  Z.leb y' (-1249).
Lemma rpf_rows_checked : forallb rpf_row_check rpf_rows = true.
Proof. vm_compute. reflexivity. Qed.

Lemma rpf_rows_integer_bound : forall y v g y' v',
  In (y,v,g,y',v') rpf_rows -> y' <= -1249.
Proof.
  intros y v g y' v' H.
  cbn [rpf_rows In] in H.
  repeat destruct H as [H | H]; try contradiction;
    inversion H; subst; lia.
Qed.

Lemma rpf_equal_bits : forall a b,
  Int.eq (Float32.to_bits a) (Float32.to_bits b) = true -> a = b.
Proof.
  intros a b H. apply Int.same_if_eq in H.
  rewrite <- (Float32.of_to_bits a), <- (Float32.of_to_bits b), H. reflexivity.
Qed.

Theorem rpf_selected_rounded_step : forall y v g y' v',
  In (y,v,g,y',v') rpf_rows ->
  rpf_next_velocity (rpf_float v) (rpf_float g) = rpf_float v' /\
  Float32.add (rpf_float y) (rpf_next_velocity (rpf_float v) (rpf_float g)) =
    rpf_float y' /\
  Float32.cmp Clt (rpf_next_velocity (rpf_float v) (rpf_float g))
    (Float32.neg (Float32.of_bits (Int.repr 1117519872))) = false /\
  y' <= -1249.
Proof.
  intros y v g y' v' Hin.
  pose proof rpf_rows_checked as Hcheck.
  rewrite forallb_forall in Hcheck. specialize (Hcheck _ Hin).
  unfold rpf_row_check in Hcheck.
  repeat rewrite andb_true_iff in Hcheck.
  destruct Hcheck as (((Hv & Hy) & Hclamp) & Hbound).
  apply negb_true_iff in Hclamp. apply Z.leb_le in Hbound.
  repeat split; auto using rpf_equal_bits.
Qed.

Lemma rpf_normal_before_suffix : forall program f e le m s le' m' tail k,
  ClightBigstep.Clight2.exec_stmt (Clight.globalenv program) e le m s E0 le' m' Out_normal ->
  @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
    (State f (Ssequence s tail) k e le m) E0 (State f tail k e le' m').
Proof.
  intros program f e le m s le' m' tail k Hrun.
  destruct (ClightBigstep.exec_stmt_steps Clight.function_entry2
    program _ _ _ _ _ _ _ _ Hrun f (Kseq tail k)) as (last & Hsteps & Hout).
  inversion Hout; subst last.
  eapply star_left; [apply step_seq| |reflexivity].
  eapply star_trans; [exact Hsteps| |reflexivity].
  apply star_one. apply step_skip_seq.
Qed.

Lemma rpf_prefix_in_actual_body : forall version e le m le' m' k,
  ClightBigstep.Clight2.exec_stmt
    (Clight.globalenv (selected_clight_target version)) e le m
    (rpf_prefix version) E0 le' m' Out_normal ->
  @Smallstep.star _ _ Clight.step2
    (Clight.globalenv (selected_clight_target version))
    (State (rank15_movement_body version) (fn_body (rank15_movement_body version))
      k e le m) E0
    (State (rank15_movement_body version) (rpf_tail version) k e le' m').
Proof.
  intros version e le m le' m' k Hrun. unfold rpf_prefix in Hrun.
  assert (Hnormalv : ibk_normal (rpf_velocity version) = true) by (destruct version; reflexivity).
  assert (Hnormalc : ibk_normal (rpf_clamp version) = true) by (destruct version; reflexivity).
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormalv Hrun)
    as (lev & mv & tv & restt & Htrace & Hvel & Hrest).
  symmetry in Htrace. apply app_eq_nil in Htrace as [-> ->].
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormalc Hrest)
    as (lec & mc & tc & post & Htrace & Hclamp & Hpos).
  symmetry in Htrace. apply app_eq_nil in Htrace as [-> ->].
  rewrite (proj1 (rpf_source version)).
  eapply star_trans; [eapply rpf_normal_before_suffix; exact Hvel| |reflexivity].
  eapply star_trans; [eapply rpf_normal_before_suffix; exact Hclamp| |reflexivity].
  eapply rpf_normal_before_suffix. exact Hpos.
Qed.

(** The output bound is now a conclusion of the executed prefix, rather than
    the premise used by [rank15_later_position_chunk_is_constructed]. *)
Definition RPFSelectedExecution : Prop :=
  forall version e le m cb ob ofs y v g y' v',
  let ge := Clight.globalenv (selected_clight_target version) in
  let ya := Ptrofs.unsigned (rank15_raw_address ofs (Int.repr 7)) in
  let va := Ptrofs.unsigned (rank15_raw_address ofs (Int.repr 10)) in
  In (y,v,g,y',v') rpf_rows ->
  e ! UOH._gCurrentObject = None ->
  Genv.find_symbol ge UOH._gCurrentObject = Some cb -> cb <> ob ->
  Mem.load Mptr m cb 0 = Some (Vptr ob ofs) ->
  le ! UOH._gravity = Some (Vsingle (rpf_float g)) ->
  le ! UOH._buoyancy = Some (Vsingle Float32.zero) ->
  Mem.load Mfloat32 m ob ya = Some (Vsingle (rpf_float y)) ->
  Mem.load Mfloat32 m ob va = Some (Vsingle (rpf_float v)) ->
  Mem.valid_access m Mfloat32 ob ya Writable ->
  Mem.valid_access m Mfloat32 ob va Writable -> ya + 4 <= va ->
  forall continuation,
  exists after,
    @Smallstep.star _ _ Clight.step2 ge
      (State (rank15_movement_body version) (fn_body (rank15_movement_body version))
        continuation e le m) E0
      (State (rank15_movement_body version) (rpf_tail version) continuation e
        (rpf_final_locals le (Vptr ob ofs) (rpf_float y) (rpf_float v) (rpf_float g))
        after) /\
    Mem.load Mfloat32 after ob ya = Some (Vsingle (rpf_float y')) /\
    Mem.load Mfloat32 after ob va = Some (Vsingle (rpf_float v')) /\
    y' <= -1249 /\
    (forall chunk rb ro,
      (rb <> ob \/ ro + size_chunk chunk <= ya \/ ya + 4 <= ro) ->
      (rb <> ob \/ ro + size_chunk chunk <= va \/ va + 4 <= ro) ->
      Mem.load chunk after rb ro = Mem.load chunk m rb ro).

Theorem rpf_selected_step_executes_and_preserves_seed : RPFSelectedExecution.
Proof.
  intros version e le m cb ob ofs y v g y' v' ge ya va Hin Hlocal Hsymbol
    Hblocks Hcurrent Hgravity Hbuoyancy Hy Hv Hywrite Hvwrite Hsep continuation.
  destruct (rpf_selected_rounded_step _ _ _ _ _ Hin) as (Hvout & Hyout & Hclamp & Hbound).
  destruct (rpf_prefix_executes version e le m cb ob ofs
    (rpf_float y) (rpf_float v) (rpf_float g) Hlocal Hsymbol Hblocks Hcurrent
    Hgravity Hbuoyancy Hy Hv Hywrite Hvwrite Hsep Hclamp)
    as (after & Hexec & Hy' & Hv' & Hframe).
  exists after. split; [eapply rpf_prefix_in_actual_body; exact Hexec|].
  rewrite Hyout in Hy'. rewrite Hvout in Hv'. auto.
Qed.

(** The selected upright closed mesh, not the taller open/waking meshes.
    This is a vertex receipt; live collision-owner selection stays separate. *)
Definition RPFClosedMesh : Prop :=
  forallb (rank15_vertex_y_at_most 204)
    (rank15_collision_vertices_of 8 UCollision.v_ssl_seg7_collision_07028274) = true /\
  forallb (rank15_vertex_y_at_most 204)
    (rank15_collision_vertices_of 8 JCollision.v_ssl_seg7_collision_07028274) = true /\
  3 * 204 = 2 * 306.
Lemma rpf_closed_mesh_checked : RPFClosedMesh.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Reboarding the same selected flight cannot add a second hand ascent.
    This geometric payoff grants all of the already-proved optimistic VSC
    rise; it does not grant reachability or a new larger Mario seed. *)
Theorem rpf_selected_ride_payoff_insufficient : forall y v g y' v' seed,
  In (y,v,g,y',v') rpf_rows -> 0 <= seed <= 31 ->
  y' - (-1534) <= rank15_upward_episode_cap /\
  y' + 306 <= rank15_observed_highest_hand_top /\
  y' + 306 + rank15_ideal_vsc_ascent seed +
    rank15_ledge_floor_query_offset + find_floor_upward_buffer < rank15_tunnel_floor_y.
Proof.
  intros y v g y' v' seed Hin Hseed.
  pose proof (rpf_rows_integer_bound _ _ _ _ _ Hin) as Hheight.
  split; [unfold rank15_upward_episode_cap; lia|].
  split; [change (y' + 306 <= -943); lia|].
  (* Consume the existing all-seeds bound below; no sampled-seed inference. *)
  assert (Htop : y' + 306 <= rank15_observed_highest_hand_top) by (change (y' + 306 <= -943); lia).
  pose proof (rank15_every_integral_seed_through_31_misses_tunnel seed (proj2 Hseed)) as Hmiss.
  eapply Z.le_lt_trans; [|exact Hmiss].
  unfold rank15_ideal_ledge_query_ceiling.
  apply Z.add_le_mono; [|reflexivity].
  apply Z.add_le_mono; [|reflexivity].
  apply Z.add_le_mono; [exact Htop|reflexivity].
Qed.

Definition EyerokRank15PoundFlightBoundary : Prop :=
  RPFPrefixedExecution /\ RPFSelectedExecution /\
  RPFRisingAction /\ RPFFallingAction /\
  RPFClosedMesh /\
  (forall y v g y' v' seed,
    In (y,v,g,y',v') rpf_rows -> 0 <= seed <= 31 ->
    y' - (-1534) <= rank15_upward_episode_cap /\
    y' + 306 <= rank15_observed_highest_hand_top /\
    y' + 306 + rank15_ideal_vsc_ascent seed +
      rank15_ledge_floor_query_offset + find_floor_upward_buffer < rank15_tunnel_floor_y).

Theorem eyerok_rank15_pound_flight_boundary_checked : EyerokRank15PoundFlightBoundary.
Proof.
  exact (conj rpf_prefix_executes (conj rpf_selected_step_executes_and_preserves_seed
    (conj rpf_rising_action_does_not_relaunch
      (conj rpf_falling_action_installs_gravity
        (conj rpf_closed_mesh_checked rpf_selected_ride_payoff_insufficient))))).
Qed.

Print Assumptions eyerok_rank15_pound_flight_boundary_checked.
