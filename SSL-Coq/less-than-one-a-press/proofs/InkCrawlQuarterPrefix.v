(** Actual post-query quarter execution for the timer-130 crawl handoff.
    The live query prefix and production of the entry state remain open. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes InkCrawlQuarterHandoff
  InkFloorHistorySource InkFloorHistoryExecution InkBackwardSource
  InkBackwardExecution InkCopyCaller InkCopyEntry InkBodyResetFrame
  InkBodyResetConstruction InkActionPassStart InkFloorResetSource
  ObjectContactNecessity ContactConsumerExecution SelectedClightTarget
  Area2Rank12BContact EyerokRank15LiveMovement InkActionPassHistory
  InkGroundBackwardSource InkMovingBackwardSource Area2Rank10AGroundHold
  InkFloorCallEffects InkFloorHistoryQuery InkPlatformWriteFrame InkFloorResetExecution.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition icqp_surface := tptr (Tstruct IFH._Surface noattr).
Definition icqp_after_queries version :=
  rank12b_drop_sequences 5 (fn_body (ifh_quarter_body version)).
Definition icqp_wall := Sassign
  (ibr_field IFH._m IFH._MarioState IFH._wall icqp_surface)
  (Etempvar IFH._upperWall icqp_surface).
Definition icqp_shell_guard := Ebinop Oand (Etempvar IFH._t'20 tuint)
  (Ebinop Oshl (Econst_int Int.one tint)
    (Econst_int (Int.repr 16) tint) tint) tuint.
Definition icqp_water_choice version := match ifh_water version with
  | Ssequence _ (Sifthenelse _ yes _) => yes | _ => Sskip end.

Lemma icqp_source : forall version,
  icqp_after_queries version = Ssequence icqp_wall (ifh_quarter_tail version) /\
  ifh_water version = Ssequence
    (Ssequence
      (Sset IFH._t'20 (ibr_field IFH._m IFH._MarioState IFH._action tuint))
      (Sifthenelse icqp_shell_guard
        (Sset IFH._t'6 (Ecast (Ebinop Olt (Etempvar IFH._floorHeight tfloat)
          (Etempvar IFH._waterLevel tfloat) tint) tbool))
        (Sset IFH._t'6 (Econst_int Int.zero tint))))
    (Sifthenelse (Etempvar IFH._t'6 tint) (icqp_water_choice version) Sskip).
Proof. intros []; split; reflexivity. Qed.

Lemma icqp_wall_layout : forall version,
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    IFH._MarioState IFH._wall 96 = true.
Proof.
  intro version. change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
    IFH._MarioState IFH._wall 96 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; reflexivity.
Qed.

(** All fields in this record are actual post-query locals, memory reads,
    or ordinary storage/alias conditions. It is not an execution oracle. *)
Record InkCrawl973QueryCut (version : GameVersion) e le m mb nb no fb sb so action wall : Prop := {
  icqp_cut_mario : le ! IFH._m = Some (Vptr mb Ptrofs.zero);
  icqp_cut_next : le ! IFH._nextPos = Some (Vptr nb no);
  icqp_cut_wall : le ! IFH._upperWall = Some wall;
  icqp_cut_wall_type : wall = Vint Int.zero \/ exists wb wo, wall = Vptr wb wo;
  icqp_cut_floor_height : le ! IFH._floorHeight = Some (Vsingle (icqh_f32 1280));
  icqp_cut_ceil_height : le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 1523));
  icqp_cut_floor_local : e ! IFH._floor = Some (fb, icqp_surface);
  icqp_cut_floor_read : Mem.load Mint32 m fb 0 = Some (Vptr sb so);
  icqp_cut_surface_valid : Mem.weak_valid_pointer m sb (Ptrofs.unsigned so) = true;
  icqp_cut_action : Mem.load Mint32 m mb 12 = Some (Vint action);
  icqp_cut_non_shell : Int.and action (Int.shl Int.one (Int.repr 16)) = Int.zero;
  icqp_cut_height : Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) = Some (Vsingle (icqh_f32 1741));
  icqp_cut_floor_separate : fb <> mb;
  icqp_cut_next_separate : nb <> mb;
  icqp_cut_wall_writable : Mem.valid_access m Mint32 mb 96 Writable
}.

Lemma icqp_store_preserves_weak_pointer : forall m mb ofs v after sb so,
  Mem.store Mint32 m mb ofs v = Some after ->
  Mem.weak_valid_pointer m sb so = true ->
  Mem.weak_valid_pointer after sb so = true.
Proof.
  intros m mb ofs v after sb so Hstore Hvalid.
  apply Mem.weak_valid_pointer_spec in Hvalid.
  apply Mem.weak_valid_pointer_spec. destruct Hvalid as [Hvalid|Hvalid].
  - left. apply Mem.valid_pointer_valid_access.
    eapply Mem.store_valid_access_1; [exact Hstore|].
    apply Mem.valid_pointer_valid_access. exact Hvalid.
  - right. apply Mem.valid_pointer_valid_access.
    eapply Mem.store_valid_access_1; [exact Hstore|].
    apply Mem.valid_pointer_valid_access. exact Hvalid.
Qed.

Definition icqp_water_locals le action :=
  PTree.set IFH._t'6 (Vint Int.zero) (PTree.set IFH._t'20 (Vint action) le).

(** Unlike the riding-shell branch, a non-shell action cannot replace the
    queried local floor with the water pseudo-floor. There is no assumption
    about water height, and no call/memory-frame premise. *)
Theorem icqp_non_shell_water_gate_executes : forall version e le m mb action,
  le ! IFH._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mint32 m mb 12 = Some (Vint action) ->
  Int.and action (Int.shl Int.one (Int.repr 16)) = Int.zero ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ifh_water version) E0 (icqp_water_locals le action) m Out_normal.
Proof.
  intros version e le m mb action Hm Haction Hflag.
  rewrite (proj2 (icqp_source version)). unfold icqp_water_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply ibc_field_read with (delta := 12) (chunk := Mint32).
      * exact Hm.
      * exact (ias_selected_action_field version).
      * reflexivity.
      * exact Haction.
    + eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
      * unfold icqp_shell_guard. eapply eval_Ebinop.
        -- apply eval_Etempvar. apply PTree.gss.
        -- eapply eval_Ebinop; [constructor|constructor|reflexivity].
        -- change (Some (Vint (Int.and action (Int.shl Int.one (Int.repr 16)))) =
             Some (Vint Int.zero)). rewrite Hflag. reflexivity.
      * reflexivity.
      * apply exec_Sset. constructor.
  - eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
    + apply eval_Etempvar. apply PTree.gss.
    + reflexivity.
    + constructor.
Qed.

Lemma icqp_floor_guard_executes : forall version ge e le m fb sb so,
  e ! IFH._floor = Some (fb, icqp_surface) ->
  Mem.load Mint32 m fb 0 = Some (Vptr sb so) ->
  Mem.weak_valid_pointer m sb (Ptrofs.unsigned so) = true ->
  ocn_exec ge e le m (ifh_missing version) E0
    (PTree.set IFH._t'21 (Vptr sb so) le) m Out_normal.
Proof.
  intros version ge e le m fb sb so Hlocal Hload Hvalid.
  assert (ifh_missing version = Ssequence
    (Sset IFH._t'21 (Evar IFH._floor icqp_surface))
    (Sifthenelse ifh_null_guard (ifh_return 2) Sskip)) as Hsource
    by (destruct version; reflexivity).
  rewrite Hsource. eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
    + apply eval_Evar_local. exact Hlocal.
    + eapply deref_loc_value with (chunk := Mint32); [reflexivity|exact Hload].
  - eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
    + unfold ifh_null_guard. eapply eval_Ebinop.
      * apply eval_Etempvar. apply PTree.gss.
      * eapply eval_Ecast; [constructor|reflexivity].
      * change (option_map Val.of_bool
          (Val.cmpu_bool (Mem.valid_pointer m) Ceq (Vptr sb so) (Vint Int.zero)) =
          Some (Vint Int.zero)).
        change (option_map Val.of_bool (if Mem.weak_valid_pointer m sb
          (Ptrofs.unsigned so) then Some false else None) =
          Some (Vint Int.zero)). rewrite Hvalid. reflexivity.
    + reflexivity.
    + constructor.
Qed.

Definition icqp_stop_locals le action sb so := icqh_stop_locals
  (icqp_water_locals (PTree.set IFH._t'21 (Vptr sb so) le) action).

(** The only memory change after the query prefix is the real wall field
    store. The query stack output and intended vector are different blocks
    from MarioState, as in normal fresh-local entries. *)
Theorem icqp_post_query_973_executes : forall version e le m mb nb no fb sb so
    action wall,
  le ! IFH._m = Some (Vptr mb Ptrofs.zero) ->
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._upperWall = Some wall ->
  (wall = Vint Int.zero \/ exists wb wo, wall = Vptr wb wo) ->
  le ! IFH._floorHeight = Some (Vsingle (icqh_f32 1280)) ->
  le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 1523)) ->
  e ! IFH._floor = Some (fb, icqp_surface) ->
  Mem.load Mint32 m fb 0 = Some (Vptr sb so) ->
  Mem.weak_valid_pointer m sb (Ptrofs.unsigned so) = true ->
  Mem.load Mint32 m mb 12 = Some (Vint action) ->
  Int.and action (Int.shl Int.one (Int.repr 16)) = Int.zero ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) =
    Some (Vsingle (icqh_f32 1741)) ->
  fb <> mb -> nb <> mb -> Mem.valid_access m Mint32 mb 96 Writable ->
  exists after,
    Mem.store Mint32 m mb 96 wall = Some after /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
      (icqp_after_queries version) E0 (icqp_stop_locals le action sb so)
      after (ifh_returned 2) /\
    (forall chunk b offset,
      (b <> mb \/ offset + size_chunk chunk <= 96 \/ 100 <= offset) ->
      Mem.load chunk after b offset = Mem.load chunk m b offset).
Proof.
  intros version e le m mb nb no fb sb so action wall Hm Hnext Hwall Hwalltype
    Hfloor Hceil Hlocal Hfloorload Hvalid Haction Hflag Hy Hfb Hnb Haccess.
  destruct (Mem.valid_access_store m Mint32 mb 96 wall Haccess) as [after Hstore].
  assert (forall chunk b offset,
    (b <> mb \/ offset + size_chunk chunk <= 96 \/ 100 <= offset) ->
    Mem.load chunk after b offset = Mem.load chunk m b offset) as Hframe.
  { intros chunk b offset Hsep. eapply Mem.load_store_other; [exact Hstore|].
    destruct Hsep as [Hsep|Hsep]; [left; congruence|right; cbn; lia]. }
  exists after. split; [exact Hstore|]. split; [|exact Hframe].
  rewrite (proj1 (icqp_source version)).
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - unfold icqp_wall. eapply exec_Sassign with (v2 := wall) (v := wall) (bf := Full).
    + eapply ibc_field_lvalue; [exact Hm|apply icqp_wall_layout].
    + apply eval_Etempvar. exact Hwall.
    + destruct Hwalltype as [-> | (wb & wo & ->)]; reflexivity.
    + eapply assign_loc_value; [reflexivity|exact Hstore].
  - assert (ifh_quarter_tail version = Ssequence (ifh_missing version)
      (Ssequence (ifh_water version) (ifh_post_water version))) as Htail
      by (destruct version; reflexivity).
    rewrite Htail. eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply icqp_floor_guard_executes; [exact Hlocal| |].
      * rewrite Hframe; [exact Hfloorload|left; exact Hfb].
      * eapply icqp_store_preserves_weak_pointer; eauto.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply icqp_non_shell_water_gate_executes.
        -- rewrite PTree.gso by discriminate. exact Hm.
        -- rewrite Hframe; [exact Haction|right; left; cbn; lia].
        -- exact Hflag.
      * unfold icqp_stop_locals. apply icqh_973_ceiling_stop_executes with (nb := nb) (no := no).
        -- unfold icqp_water_locals. repeat rewrite PTree.gso by discriminate. exact Hnext.
        -- unfold icqp_water_locals. repeat rewrite PTree.gso by discriminate. exact Hfloor.
        -- unfold icqp_water_locals. repeat rewrite PTree.gso by discriminate. exact Hceil.
        -- rewrite Hframe; [exact Hy|left; exact Hnb].
Qed.

Definition InkCrawl973PostQueryExecution : Prop :=
  forall version e le m mb nb no fb sb so action wall,
  InkCrawl973QueryCut version e le m mb nb no fb sb so action wall ->
  exists after,
    Mem.store Mint32 m mb 96 wall = Some after /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
      (icqp_after_queries version) E0 (icqp_stop_locals le action sb so)
      after (ifh_returned 2) /\
    (forall chunk b offset,
      (b <> mb \/ offset + size_chunk chunk <= 96 \/ 100 <= offset) ->
      Mem.load chunk after b offset = Mem.load chunk m b offset).

Theorem icqp_query_cut_executes : InkCrawl973PostQueryExecution.
Proof.
  intros version e le m mb nb no fb sb so action wall Hcut.
  destruct Hcut. eapply icqp_post_query_973_executes; eauto.
Qed.

Definition icqp_crawling := Int.repr 67142728.
Definition icqp_moving_body version := match version with
| VersionUS => us_mario_actions_moving.f_mario_execute_moving_action
| VersionJP => jp_mario_actions_moving.f_mario_execute_moving_action end.
Definition icqp_moving_cases version := match
  ibk_head (rank12b_drop_sequences 2 (fn_body (icqp_moving_body version))) with
| Ssequence _ (Sswitch _ cases) => cases | _ => LSnil end.
Definition icqp_crawling_case version := match
  select_switch 67142728 (icqp_moving_cases version) with
| LScons _ body _ => body | _ => Sskip end.

(** The bit certificate is tied to the generated dispatch case for crawling.
    It is not a claim that a controller has reached that action. *)
Theorem icqp_crawling_source_and_flag :
  (forall version, icqp_crawling_case version = Ssequence
    (Ssequence
      (Scall (Some IMB._t'10)
        (Evar IMB._act_crawling (Tfunction
          [tptr (Tstruct IMB._MarioState noattr)] tint cc_default))
        [Etempvar IMB._m (tptr (Tstruct IMB._MarioState noattr))])
      (Sset IMB._cancel (Etempvar IMB._t'10 tint))) Sbreak) /\
  Int.and icqp_crawling (Int.shl Int.one (Int.repr 16)) = Int.zero.
Proof. split; [intros []; reflexivity|vm_compute; reflexivity]. Qed.

(** These cells are simultaneously outside the actual wall write. In
    particular the remembered floor pointer is 104, floorHeight 112; the
    local query's floor block and nextPos block are separate from Mario. *)
Lemma icqp_mario_cell_ranges :
  forall offset, In offset [12; 60; 64; 68; 104; 112] ->
    offset + 4 <= 96 \/ 100 <= offset.
Proof.
  intros offset H. cbn in H.
  destruct H as [<-|[<-|[<-|[<-|[<-|[<-|[]]]]]]]; lia.
Qed.

Lemma icqp_remembered_cell_layout : forall version,
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    IFH._MarioState IFH._floor 104 = true /\
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    IFH._MarioState IFH._floorHeight 112 = true /\
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    IFH._MarioState IFH._pos 60 = true.
Proof.
  intro version. split; [apply ifh_selected_floor_pointer_field|].
  split; [apply ifr_selected_floor_field|exact (proj1 (ibcc_selected_fields version))].
Qed.

Lemma icqp_real_entry_has_separate_floor : forall version ge start mb nb e le entry fb,
  Mem.valid_block start mb ->
  function_entry2 ge (ifh_quarter_body version)
    [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero] start e le entry ->
  e ! IFH._floor = Some (fb, icqp_surface) -> fb <> mb.
Proof.
  intros version ge start mb nb e le entry fb Hvalid Hentry Hfloor.
  inversion Hentry; subst.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    destruct (ipw_alloc_frame _ _ _ _ _ _ Ha mb Hvalid
      ltac:(intros id b ty Hread; rewrite PTree.gempty in Hread; discriminate))
      as (Hlocals & _) end.
  eapply Hlocals; exact Hfloor.
Qed.

Lemma icqp_ground_entry_has_separate_vector : forall version ge start mb e le entry nb,
  Mem.valid_block start mb ->
  function_entry2 ge (igb_body version) [Vptr mb Ptrofs.zero] start e le entry ->
  e ! IFR._intendedPos = Some (nb, tarray tfloat 3) -> nb <> mb.
Proof.
  intros version ge start mb e le entry nb Hvalid Hentry Hvector.
  inversion Hentry; subst.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    destruct (ipw_alloc_frame _ _ _ _ _ _ Ha mb Hvalid
      ltac:(intros id b ty Hread; rewrite PTree.gempty in Hread; discriminate))
      as (Hlocals & _) end.
  eapply Hlocals; exact Hvector.
Qed.

Definition InkCrawl973RememberedCachePreservation : Prop :=
  forall version e le m mb nb no fb sb so wall remembered,
  InkCrawl973QueryCut version e le m mb nb no fb sb so icqp_crawling wall ->
  Mem.load Mint32 m mb 104 = Some remembered ->
  Mem.load Mfloat32 m mb 112 = Some (Vsingle (icqh_f32 768)) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle (icqh_f32 1741)) ->
  exists after,
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
      (icqp_after_queries version) E0 (icqp_stop_locals le icqp_crawling sb so)
      after (ifh_returned 2) /\
    Mem.load Mint32 after mb 104 = Some remembered /\
    Mem.load Mfloat32 after mb 112 = Some (Vsingle (icqh_f32 768)) /\
    Mem.load Mfloat32 after mb 64 = Some (Vsingle (icqh_f32 1741)) /\
    Mem.load Mint32 after mb 12 = Some (Vint icqp_crawling) /\
    Mem.load Mfloat32 after mb 60 = Mem.load Mfloat32 m mb 60 /\
    Mem.load Mfloat32 after mb 68 = Mem.load Mfloat32 m mb 68.

Theorem icqp_crawling_preserves_768_cache : InkCrawl973RememberedCachePreservation.
Proof.
  intros version e le m mb nb no fb sb so wall remembered Hcut Hpointer Hcache Hy.
  pose proof (icqp_cut_action _ _ _ _ _ _ _ _ _ _ _ _ Hcut) as Haction.
  destruct (icqp_query_cut_executes version e le m mb nb no fb sb so
    icqp_crawling wall Hcut) as (after & Hstore & Hrun & Hframe).
  exists after. split; [exact Hrun|]. repeat split.
  - rewrite Hframe; [exact Hpointer|right; right; lia].
  - rewrite Hframe; [exact Hcache|right; right; lia].
  - rewrite Hframe; [exact Hy|right; left; cbn; lia].
  - rewrite Hframe; [exact Haction|right; left; cbn; lia].
  - apply Hframe. right; left; cbn; lia.
  - apply Hframe. right; left; cbn; lia.
Qed.

Definition icqp_queries version := ocn_prefix_items 5
  (fn_body (ifh_quarter_body version)).

(** No query execution is invented: entry, the five real prefix statements,
    their resulting cut state, and the real stack free remain explicit.
    The previously supplied return 2 is instead constructed from that cut. *)
Theorem icqp_real_quarter_returns_two_from_queries :
  forall version start mb nb e entry_le entry_m cut_le cut_m trace fb sb so
    action wall written returned,
  function_entry2 (Clight.globalenv (selected_clight_target version))
    (ifh_quarter_body version) [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero]
    start e entry_le entry_m ->
  iap_stage_chain (Clight.globalenv (selected_clight_target version))
    e entry_le entry_m (icqp_queries version) trace cut_le cut_m ->
  InkCrawl973QueryCut version e cut_le cut_m mb nb Ptrofs.zero fb sb so action wall ->
  Mem.store Mint32 cut_m mb 96 wall = Some written ->
  Mem.free_list written (blocks_of_env
    (Clight.globalenv (selected_clight_target version)) e) = Some returned ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) start
    (Internal (ifh_quarter_body version)) [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero]
    trace returned (Vint (Int.repr 2)).
Proof.
  intros version start mb nb e entry_le entry_m cut_le cut_m trace fb sb so
    action wall written returned Hentry Hqueries Hcut Hstore Hfree.
  destruct (icqp_query_cut_executes version e cut_le cut_m mb nb Ptrofs.zero
    fb sb so action wall Hcut) as (after & Hafter & Htail & Hframe).
  assert (after = written) by congruence. subst after.
  eapply eval_funcall_internal.
  - exact Hentry.
  - assert (fn_body (ifh_quarter_body version) =
      ocn_prepend (icqp_queries version) (icqp_after_queries version)) as Hbody
      by (destruct version; reflexivity).
    rewrite Hbody. rewrite <- (app_nil_r trace) at 1.
    eapply ibc_chain_then_tail; [exact Hqueries|exact Htail].
  - destruct version; cbn [ifh_quarter_body fn_return ifh_returned outcome_result_value];
      split; solve [discriminate | reflexivity].
  - exact Hfree.
Qed.

Definition icqp_caller_tail version := rank12b_drop_sequences 3 (icqh_iteration version).
Definition icqp_quarter_call := Scall (Some IFR._t'1)
  (Evar IFR._perform_ground_quarter_step (Tfunction
    [tptr (Tstruct IFR._MarioState noattr); tptr tfloat] tint cc_default))
  [Etempvar IFR._m (tptr (Tstruct IFR._MarioState noattr));
   Evar IFR._intendedPos (tarray tfloat 3)].
Definition icqp_caller_last le := PTree.set IFR._t'2 (Vint Int.one)
  (PTree.set IFR._stepResult (Vint (Int.repr 2))
    (PTree.set IFR._t'1 (Vint (Int.repr 2)) le)).

Lemma icqp_caller_source : forall version,
  icqp_caller_tail version = Ssequence
    (Ssequence icqp_quarter_call
      (Sset IFR._stepResult (Etempvar IFR._t'1 tint))) (icqh_break_gate version).
Proof. intros []; reflexivity. Qed.

Theorem icqp_actual_quarter_return_executes_break :
  forall version e le m mb nb trace after,
  e ! IFR._perform_ground_quarter_step = None ->
  e ! IFR._intendedPos = Some (nb, tarray tfloat 3) ->
  le ! IFR._m = Some (Vptr mb Ptrofs.zero) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (ifh_quarter_body version)) [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero]
    trace after (Vint (Int.repr 2)) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (icqp_caller_tail version) trace (icqp_caller_last le) after Out_break.
Proof.
  intros version e le m mb nb trace after Hglobal Hvector Hm Hcall.
  destruct (ifh_selected_quarter_body_resolves version) as (fn & Hsymbol & Hfun).
  rewrite icqp_caller_source. unfold icqp_caller_last.
  rewrite <- (app_nil_r trace) at 1.
  eapply exec_Sseq_1 with (t1 := trace) (t2 := E0).
  - rewrite <- (app_nil_r trace) at 1.
    eapply exec_Sseq_1 with (t1 := trace) (t2 := E0).
    + unfold icqp_quarter_call. eapply exec_Scall with
        (vf := Vptr fn Ptrofs.zero) (f := Internal (ifh_quarter_body version))
        (vargs := [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero])
        (vres := Vint (Int.repr 2)).
      * reflexivity.
      * eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
        -- apply eval_Evar_global; [exact Hglobal|exact Hsymbol].
        -- apply deref_loc_reference. reflexivity.
      * econstructor; [apply eval_Etempvar; exact Hm|reflexivity|].
        econstructor.
        -- eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
           ++ apply eval_Evar_local. exact Hvector.
           ++ apply deref_loc_reference. reflexivity.
        -- reflexivity.
        -- constructor.
      * exact Hfun.
      * destruct version; reflexivity.
      * exact Hcall.
    + apply exec_Sset. apply eval_Etempvar. apply PTree.gss.
  - apply icqh_result_two_executes_break. apply PTree.gss.
Qed.

(** This combines the real callee and caller. There is no independent
    assumption that the caller's stepResult happens to equal 2. It starts
    after the caller's intended-coordinate stores, and still requires the
    actual query prefix to reach the certified numeric/alias cut. *)
Definition InkCrawl973QueriesToCallerBreak : Prop :=
  forall version caller_e caller_le start mb nb e entry_le entry_m cut_le cut_m
    trace fb sb so action wall written returned,
  caller_e ! IFR._perform_ground_quarter_step = None ->
  caller_e ! IFR._intendedPos = Some (nb, tarray tfloat 3) ->
  caller_le ! IFR._m = Some (Vptr mb Ptrofs.zero) ->
  function_entry2 (Clight.globalenv (selected_clight_target version))
    (ifh_quarter_body version) [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero]
    start e entry_le entry_m ->
  iap_stage_chain (Clight.globalenv (selected_clight_target version))
    e entry_le entry_m (icqp_queries version) trace cut_le cut_m ->
  InkCrawl973QueryCut version e cut_le cut_m mb nb Ptrofs.zero fb sb so action wall ->
  Mem.store Mint32 cut_m mb 96 wall = Some written ->
  Mem.free_list written (blocks_of_env
    (Clight.globalenv (selected_clight_target version)) e) = Some returned ->
  ocn_exec (Clight.globalenv (selected_clight_target version))
    caller_e caller_le start (icqp_caller_tail version) trace
    (icqp_caller_last caller_le) returned Out_break.

Theorem icqp_queries_to_caller_break : InkCrawl973QueriesToCallerBreak.
Proof.
  intros version caller_e caller_le start mb nb e entry_le entry_m cut_le cut_m
    trace fb sb so action wall written returned Hglobal Hvector Hm
    Hentry Hqueries Hcut Hstore Hfree.
  eapply icqp_actual_quarter_return_executes_break; [exact Hglobal|exact Hvector|exact Hm|].
  eapply icqp_real_quarter_returns_two_from_queries; eauto.
Qed.

Definition InkCrawl973QueriesToCallerBreakAndFrame : Prop :=
  forall version caller_e caller_le start mb nb e entry_le entry_m cut_le cut_m
    trace fb sb so action wall written returned,
  Mem.valid_block start mb ->
  caller_e ! IFR._perform_ground_quarter_step = None ->
  caller_e ! IFR._intendedPos = Some (nb, tarray tfloat 3) ->
  caller_le ! IFR._m = Some (Vptr mb Ptrofs.zero) ->
  function_entry2 (Clight.globalenv (selected_clight_target version))
    (ifh_quarter_body version) [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero]
    start e entry_le entry_m ->
  iap_stage_chain (Clight.globalenv (selected_clight_target version))
    e entry_le entry_m (icqp_queries version) trace cut_le cut_m ->
  InkCrawl973QueryCut version e cut_le cut_m mb nb Ptrofs.zero fb sb so action wall ->
  Mem.store Mint32 cut_m mb 96 wall = Some written ->
  Mem.free_list written (blocks_of_env
    (Clight.globalenv (selected_clight_target version)) e) = Some returned ->
  ocn_exec (Clight.globalenv (selected_clight_target version))
    caller_e caller_le start (icqp_caller_tail version) trace
    (icqp_caller_last caller_le) returned Out_break /\
  (forall chunk offset, offset + size_chunk chunk <= 96 \/ 100 <= offset ->
    Mem.load chunk returned mb offset = Mem.load chunk cut_m mb offset).

(** The real quarter's two stack allocations cannot free pre-existing
    MarioState. Thus the cache/position/action frame reaches the caller,
    including function return, without assuming a whole-call frame. *)
Theorem icqp_queries_to_caller_break_and_frame : InkCrawl973QueriesToCallerBreakAndFrame.
Proof.
  intros version caller_e caller_le start mb nb e entry_le entry_m cut_le cut_m
    trace fb sb so action wall written returned Hvalid Hglobal Hvector Hm
    Hentry Hqueries Hcut Hstore Hfree.
  split.
  - eapply icqp_queries_to_caller_break; eauto.
  - intros chunk offset Hrange.
    destruct (rank10h_entry_storage version _ start mb nb e entry_le entry_m
      Hvalid Hentry) as [_ Hfrees].
    rewrite (ifc_free_list_frame _ _ _ _ _ _ Hfrees Hfree).
    eapply Mem.load_store_other; [exact Hstore|].
    right. cbn. lia.
Qed.

Definition InkCrawlQuarterPrefixBoundary : Prop :=
  InkCrawl973PostQueryExecution /\ InkCrawl973RememberedCachePreservation /\
  InkCrawl973QueriesToCallerBreakAndFrame /\
  Int.and icqp_crawling (Int.shl Int.one (Int.repr 16)) = Int.zero.

Theorem icqp_crawl_quarter_prefix_checked : InkCrawlQuarterPrefixBoundary.
Proof.
  split; [exact icqp_query_cut_executes|].
  split; [exact icqp_crawling_preserves_768_cache|].
  split; [exact icqp_queries_to_caller_break_and_frame|].
  exact (proj2 icqp_crawling_source_and_flag).
Qed.
