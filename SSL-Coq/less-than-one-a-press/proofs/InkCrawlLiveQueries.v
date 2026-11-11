(** The five real query calls before the stopped crawl quarter, on one
    memory chain. Numeric live-query results remain explicit; no end-of-
    prefix cache is supplied independently of the earlier memory. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_object_list_processor.
From LessThanOneAPress.Proofs Require Import GameTypes InkCrawlQuarterPrefix
  InkCrawlQuarterHandoff InkStoppedFloorQuery InkFloorHistorySource
  InkFloorHistoryExecution InkFloorHistoryCall InkFloorCallEffects
  InkBackwardSource InkBackwardExecution InkCopyCaller InkCopyEntry
  InkFloorResetSource InkFloorResetExecution InkPlatformWriteFrame InkBodyResetConstruction
  InkActionPassHistory ObjectContactNecessity ContactConsumerExecution
  SelectedClightTarget UpperElevatorQueryResolution TeleporterHeldInitializer
  Area2Rank12BContact.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition icl_wall_temp (upper : bool) := if upper then IFH._t'2 else IFH._t'1.
Definition icl_wall_local (upper : bool) := if upper then IFH._upperWall else IFH._lowerWall.
Definition icl_wall_offset (upper : bool) := Float32.of_bits
  (Int.repr (if upper then 1114636288 else 1106247680)).
Definition icl_wall_radius (upper : bool) := Float32.of_bits
  (Int.repr (if upper then 1112014848 else 1103101952)).
Definition icl_wall_stage version (upper : bool) := ibk_head
  (rank12b_drop_sequences (if upper then 1 else 0) (fn_body (ifh_quarter_body version))).
Definition icl_ceil_stage version := ibk_head
  (rank12b_drop_sequences 3 (fn_body (ifh_quarter_body version))).
Definition icl_water_stage version := ibk_head
  (rank12b_drop_sequences 4 (fn_body (ifh_quarter_body version))).
Definition icl_wall_le upper (value : val) le :=
  PTree.set (icl_wall_local upper) value (PTree.set (icl_wall_temp upper) value le).
Definition icl_floor_le x y z height le :=
  PTree.set IFH._floorHeight (Vsingle height)
  (PTree.set IFH._t'3 (Vsingle height) (PTree.set IFH._t'26 (Vsingle z)
  (PTree.set IFH._t'25 (Vsingle y) (PTree.set IFH._t'24 (Vsingle x) le)))).
Definition icl_ceil_le height le := PTree.set IFH._ceilHeight (Vsingle height)
  (PTree.set IFH._t'4 (Vsingle height) le).
Definition icl_water_le x z height le := PTree.set IFH._waterLevel (Vsingle height)
  (PTree.set IFH._t'5 (Vsingle height) (PTree.set IFH._t'23 (Vsingle z)
  (PTree.set IFH._t'22 (Vsingle x) le))).

Lemma icl_selected_call : forall version native e le before id tys result_ty
    actuals values trace after result,
  e ! (ueqr_native_ident native) = None ->
  type_of_function (ueqr_native_body version native) = Tfunction tys result_ty cc_default ->
  eval_exprlist (Clight.globalenv (selected_clight_target version)) e le before
    actuals tys values ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (ueqr_native_body version native)) values trace after result ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (Scall (Some id) (Evar (ueqr_native_ident native)
      (Tfunction tys result_ty cc_default)) actuals) trace
    (PTree.set id result le) after Out_normal.
Proof.
  intros version native e le before id tys result_ty actuals values trace after result
    Hlocal Htype Hargs Hcall.
  destruct (upper_elevator_selected_query_body_resolves version native)
    as (callee & Hsymbol & Hfun).
  eapply exec_Scall with (vf := Vptr callee Ptrofs.zero)
    (f := Internal (ueqr_native_body version native)) (vargs := values) (vres := result).
  - reflexivity.
  - eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
    + apply eval_Evar_global; [exact Hlocal|exact Hsymbol].
    + apply deref_loc_reference. reflexivity.
  - exact Hargs.
  - exact Hfun.
  - exact Htype.
  - exact Hcall.
Qed.

Lemma icl_wall_stage_executes : forall version upper e le m nb trace after result,
  e ! IFH._resolve_and_return_wall_collisions = None ->
  le ! IFH._nextPos = Some (Vptr nb Ptrofs.zero) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (ueqr_native_body version UEQRResolveWall))
    [Vptr nb Ptrofs.zero; Vsingle (icl_wall_offset upper); Vsingle (icl_wall_radius upper)]
    trace after result ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (icl_wall_stage version upper) trace (icl_wall_le upper result le) after Out_normal.
Proof.
  intros version upper e le m nb trace after result Hlocal Hnext Hcall.
  assert (icl_wall_stage version upper = Ssequence
    (Scall (Some (icl_wall_temp upper))
      (Evar IFH._resolve_and_return_wall_collisions (Tfunction
        [tptr tfloat; tfloat; tfloat] icqp_surface cc_default))
      [Etempvar IFH._nextPos (tptr tfloat);
       Econst_single (icl_wall_offset upper) tfloat;
       Econst_single (icl_wall_radius upper) tfloat])
    (Sset (icl_wall_local upper) (Etempvar (icl_wall_temp upper) icqp_surface))) as Hshape
    by (destruct version, upper; reflexivity).
  rewrite Hshape. unfold icl_wall_le. rewrite <- (app_nil_r trace) at 1.
  eapply exec_Sseq_1 with (t1 := trace) (t2 := E0).
  - eapply icl_selected_call with (native := UEQRResolveWall).
    + exact Hlocal.
    + destruct version; reflexivity.
    + econstructor; [apply eval_Etempvar; exact Hnext|reflexivity|].
      econstructor; [constructor|reflexivity|].
      econstructor; [constructor|reflexivity|constructor].
    + exact Hcall.
  - apply exec_Sset. apply eval_Etempvar. apply PTree.gss.
Qed.

Lemma icl_next_read : forall ge e le m nb n value,
  le ! IFH._nextPos = Some (Vptr nb Ptrofs.zero) ->
  Mem.load Mfloat32 m nb (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero
    (Ptrofs.mul (Ptrofs.repr 4) (ptrofs_of_int Signed (Int.repr n))))) =
    Some (Vsingle value) ->
  eval_expr ge e le m (ifh_next n) (Vsingle value).
Proof.
  intros ge e le m nb n value Hnext Hload. unfold ifh_next.
  eapply eval_Elvalue.
  - apply eval_Ederef. eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hnext.
    + constructor.
    + reflexivity.
  - eapply deref_loc_value with (chunk := Mfloat32); [reflexivity|].
    exact Hload.
Qed.

Lemma icl_floor_stage_executes : forall version e le m nb fb x y z height trace after,
  e ! IFH._find_floor = None -> e ! IFH._floor = Some (fb, icqp_surface) ->
  le ! IFH._nextPos = Some (Vptr nb Ptrofs.zero) ->
  Mem.load Mfloat32 m nb 0 = Some (Vsingle x) ->
  Mem.load Mfloat32 m nb 4 = Some (Vsingle y) ->
  Mem.load Mfloat32 m nb 8 = Some (Vsingle z) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (ueqr_native_body version UEQRFindFloor))
    [Vsingle x; Vsingle y; Vsingle z; Vptr fb Ptrofs.zero] trace after (Vsingle height) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (isfq_query version) trace (icl_floor_le x y z height le) after Out_normal.
Proof.
  intros version e le m nb fb x y z height trace after Hlocal Hfloor Hnext Hx Hy Hz Hcall.
  rewrite isfq_source. unfold icl_floor_le.
  rewrite <- (app_nil_r trace) at 1. eapply exec_Sseq_1 with (t1 := trace) (t2 := E0).
  - rewrite <- (app_nil_l trace) at 1. eapply exec_Sseq_1 with (t1 := E0) (t2 := trace).
    + apply exec_Sset. eapply icl_next_read; [exact Hnext|exact Hx].
    + rewrite <- (app_nil_l trace) at 1. eapply exec_Sseq_1 with (t1 := E0) (t2 := trace).
      * apply exec_Sset. eapply icl_next_read.
        -- rewrite PTree.gso by discriminate. exact Hnext.
        -- exact Hy.
      * rewrite <- (app_nil_l trace) at 1. eapply exec_Sseq_1 with (t1 := E0) (t2 := trace).
        -- apply exec_Sset. eapply icl_next_read.
           ++ repeat rewrite PTree.gso by discriminate. exact Hnext.
           ++ exact Hz.
        -- unfold isfq_call. eapply icl_selected_call with (native := UEQRFindFloor).
           ++ exact Hlocal.
           ++ destruct version; reflexivity.
           ++ econstructor.
              ** apply eval_Etempvar. repeat rewrite PTree.gso by discriminate. apply PTree.gss.
              ** reflexivity.
              ** econstructor.
                 --- apply eval_Etempvar. rewrite PTree.gso by discriminate. apply PTree.gss.
                 --- reflexivity.
                 --- econstructor; [apply eval_Etempvar; apply PTree.gss|reflexivity|].
                     econstructor.
                     { apply eval_Eaddrof. apply eval_Evar_local. exact Hfloor. }
                     { reflexivity. }
                     constructor.
           ++ exact Hcall.
  - apply exec_Sset. apply eval_Etempvar. apply PTree.gss.
Qed.

Lemma icl_ceil_stage_executes : forall version e le m nb cb floor ceiling trace after,
  e ! IFH._vec3f_find_ceil = None -> e ! IFH._ceil = Some (cb, icqp_surface) ->
  le ! IFH._nextPos = Some (Vptr nb Ptrofs.zero) ->
  le ! IFH._floorHeight = Some (Vsingle floor) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (ueqr_native_body version UEQRVecCeil))
    [Vptr nb Ptrofs.zero; Vsingle floor; Vptr cb Ptrofs.zero]
    trace after (Vsingle ceiling) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (icl_ceil_stage version) trace (icl_ceil_le ceiling le) after Out_normal.
Proof.
  intros version e le m nb cb floor ceiling trace after Hlocal Hceil Hnext Hfloor Hcall.
  assert (icl_ceil_stage version = Ssequence
    (Scall (Some IFH._t'4) (Evar IFH._vec3f_find_ceil (Tfunction
      [tptr tfloat; tfloat; tptr icqp_surface] tfloat cc_default))
      [Etempvar IFH._nextPos (tptr tfloat); Etempvar IFH._floorHeight tfloat;
       Eaddrof (Evar IFH._ceil icqp_surface) (tptr icqp_surface)])
    (Sset IFH._ceilHeight (Etempvar IFH._t'4 tfloat))) as Hshape
    by (destruct version; reflexivity).
  rewrite Hshape. unfold icl_ceil_le. rewrite <- (app_nil_r trace) at 1.
  eapply exec_Sseq_1 with (t1 := trace) (t2 := E0).
  - eapply icl_selected_call with (native := UEQRVecCeil).
    + exact Hlocal.
    + destruct version; reflexivity.
    + econstructor; [apply eval_Etempvar; exact Hnext|reflexivity|].
      econstructor; [apply eval_Etempvar; exact Hfloor|reflexivity|].
      econstructor.
      * apply eval_Eaddrof. apply eval_Evar_local. exact Hceil.
      * reflexivity.
      * constructor.
    + exact Hcall.
  - apply exec_Sset. apply eval_Etempvar. apply PTree.gss.
Qed.

Lemma icl_water_stage_executes : forall version e le m nb x z water trace after,
  e ! IFH._find_water_level = None ->
  le ! IFH._nextPos = Some (Vptr nb Ptrofs.zero) ->
  Mem.load Mfloat32 m nb 0 = Some (Vsingle x) ->
  Mem.load Mfloat32 m nb 8 = Some (Vsingle z) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (thi_body version THIFindWater)) [Vsingle x; Vsingle z]
    trace after (Vsingle water) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (icl_water_stage version) trace (icl_water_le x z water le) after Out_normal.
Proof.
  intros version e le m nb x z water trace after Hlocal Hnext Hx Hz Hcall.
  assert (icl_water_stage version = Ssequence
    (Ssequence (Sset IFH._t'22 (ifh_next 0))
      (Ssequence (Sset IFH._t'23 (ifh_next 2))
        (Scall (Some IFH._t'5) (Evar IFH._find_water_level
          (Tfunction [tfloat; tfloat] tfloat cc_default))
          [Etempvar IFH._t'22 tfloat; Etempvar IFH._t'23 tfloat])))
    (Sset IFH._waterLevel (Etempvar IFH._t'5 tfloat))) as Hshape
    by (destruct version; reflexivity).
  rewrite Hshape. unfold icl_water_le.
  rewrite <- (app_nil_r trace) at 1. eapply exec_Sseq_1 with (t1 := trace) (t2 := E0).
  - rewrite <- (app_nil_l trace) at 1. eapply exec_Sseq_1 with (t1 := E0) (t2 := trace).
    + apply exec_Sset. eapply icl_next_read; [exact Hnext|exact Hx].
    + rewrite <- (app_nil_l trace) at 1. eapply exec_Sseq_1 with (t1 := E0) (t2 := trace).
      * apply exec_Sset. eapply icl_next_read.
        -- rewrite PTree.gso by discriminate. exact Hnext.
        -- exact Hz.
      * destruct (thi_selected_callees_resolve version THIFindWater)
          as (callee & Hsymbol & Hfun).
        eapply exec_Scall with (vf := Vptr callee Ptrofs.zero)
          (f := Internal (thi_body version THIFindWater))
          (vargs := [Vsingle x; Vsingle z]) (vres := Vsingle water).
        -- reflexivity.
        -- eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
           ++ apply eval_Evar_global; [exact Hlocal|exact Hsymbol].
           ++ apply deref_loc_reference. reflexivity.
        -- econstructor.
           ++ apply eval_Etempvar. rewrite PTree.gso by discriminate. apply PTree.gss.
           ++ reflexivity.
           ++ econstructor; [apply eval_Etempvar; apply PTree.gss|reflexivity|constructor].
        -- exact Hfun.
        -- destruct version; reflexivity.
        -- exact Hcall.
  - apply exec_Sset. apply eval_Etempvar. apply PTree.gss.
Qed.

(** Only these six Mario cells are residual frames for the two wall calls
    and the ceiling wrapper. No complete-memory frame is postulated. *)
Definition icl_state_cells : list (memory_chunk * Z) :=
  [(Mint32,12); (Mfloat32,60); (Mfloat32,64); (Mfloat32,68); (Mint32,104); (Mfloat32,112)].
Definition icl_state_frame mb before after : Prop := forall chunk ofs,
  In (chunk,ofs) icl_state_cells -> Mem.load chunk after mb ofs = Mem.load chunk before mb ofs.

Set Implicit Arguments.
Record InkCrawlLiveQueryChain (version : GameVersion) (entry : mem) (mb nb fb cb : block) : Type := {
  icl_lower_memory : mem; icl_upper_memory : mem; icl_floor_memory : mem;
  icl_ceil_memory : mem; icl_water_memory : mem;
  icl_lower_trace : trace; icl_upper_trace : trace; icl_floor_trace : trace;
  icl_ceil_trace : trace; icl_water_trace : trace;
  icl_lower_result : val; icl_upper_result : val;
  icl_x : float32; icl_z : float32;
  icl_water_x : float32; icl_water_z : float32; icl_water_result : float32;
  icl_surface_block : block; icl_surface_offset : ptrofs;
  icl_lower_run : ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) entry
    (Internal (ueqr_native_body version UEQRResolveWall))
    [Vptr nb Ptrofs.zero; Vsingle (icl_wall_offset false); Vsingle (icl_wall_radius false)]
    icl_lower_trace icl_lower_memory icl_lower_result;
  icl_upper_run : ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) icl_lower_memory
    (Internal (ueqr_native_body version UEQRResolveWall))
    [Vptr nb Ptrofs.zero; Vsingle (icl_wall_offset true); Vsingle (icl_wall_radius true)]
    icl_upper_trace icl_upper_memory icl_upper_result;
  icl_floor_x : Mem.load Mfloat32 icl_upper_memory nb 0 = Some (Vsingle icl_x);
  icl_floor_y : Mem.load Mfloat32 icl_upper_memory nb 4 = Some (Vsingle (icqh_f32 1741));
  icl_floor_z : Mem.load Mfloat32 icl_upper_memory nb 8 = Some (Vsingle icl_z);
  icl_floor_run : ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) icl_upper_memory
    (Internal (ueqr_native_body version UEQRFindFloor))
    [Vsingle icl_x; Vsingle (icqh_f32 1741); Vsingle icl_z; Vptr fb Ptrofs.zero]
    icl_floor_trace icl_floor_memory (Vsingle (icqh_f32 1280));
  icl_floor_pointer : Mem.load Mint32 icl_floor_memory fb 0 =
    Some (Vptr icl_surface_block icl_surface_offset);
  icl_ceil_run : ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) icl_floor_memory
    (Internal (ueqr_native_body version UEQRVecCeil))
    [Vptr nb Ptrofs.zero; Vsingle (icqh_f32 1280); Vptr cb Ptrofs.zero]
    icl_ceil_trace icl_ceil_memory (Vsingle (icqh_f32 1523));
  icl_water_read_x : Mem.load Mfloat32 icl_ceil_memory nb 0 = Some (Vsingle icl_water_x);
  icl_water_read_z : Mem.load Mfloat32 icl_ceil_memory nb 8 = Some (Vsingle icl_water_z);
  icl_water_run : ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) icl_ceil_memory
    (Internal (thi_body version THIFindWater)) [Vsingle icl_water_x; Vsingle icl_water_z]
    icl_water_trace icl_water_memory (Vsingle icl_water_result);
  icl_lower_state_frame : icl_state_frame mb entry icl_lower_memory;
  icl_upper_state_frame : icl_state_frame mb icl_lower_memory icl_upper_memory;
  icl_ceil_state_frame : icl_state_frame mb icl_floor_memory icl_ceil_memory;
  icl_ceil_preserves_floor_output : Mem.load Mint32 icl_ceil_memory fb 0 =
    Mem.load Mint32 icl_floor_memory fb 0;
  icl_live_surface : Mem.weak_valid_pointer icl_ceil_memory icl_surface_block
    (Ptrofs.unsigned icl_surface_offset) = true;
  icl_ceil_intended_y : Mem.load Mfloat32 icl_ceil_memory nb 4 = Some (Vsingle (icqh_f32 1741));
  icl_upper_is_pointer : icl_upper_result = Vint Int.zero \/
    exists b ofs, icl_upper_result = Vptr b ofs;
  icl_wall_writable : Mem.valid_access icl_ceil_memory Mint32 mb 96 Writable
}.
Unset Implicit Arguments.

Definition icl_chain_trace {version entry mb nb fb cb}
    (q : InkCrawlLiveQueryChain version entry mb nb fb cb) :=
  icl_lower_trace q ++ (icl_upper_trace q ++ (icl_floor_trace q ++
    (icl_ceil_trace q ++ (icl_water_trace q ++ E0)))).
Definition icl_chain_le {version entry mb nb fb cb}
    (q : InkCrawlLiveQueryChain version entry mb nb fb cb) le :=
  icl_water_le (icl_water_x q) (icl_water_z q) (icl_water_result q)
  (icl_ceil_le (icqh_f32 1523)
  (icl_floor_le (icl_x q) (icqh_f32 1741) (icl_z q) (icqh_f32 1280)
  (icl_wall_le true (icl_upper_result q) (icl_wall_le false (icl_lower_result q) le)))).

Theorem icl_five_real_calls_construct_prefix : forall version entry mb nb fb cb e le
    (q : InkCrawlLiveQueryChain version entry mb nb fb cb),
  e ! IFH._resolve_and_return_wall_collisions = None ->
  e ! IFH._find_floor = None -> e ! IFH._vec3f_find_ceil = None ->
  e ! IFH._find_water_level = None ->
  e ! IFH._floor = Some (fb, icqp_surface) -> e ! IFH._ceil = Some (cb, icqp_surface) ->
  le ! IFH._nextPos = Some (Vptr nb Ptrofs.zero) ->
  iap_stage_chain (Clight.globalenv (selected_clight_target version)) e le entry
    (icqp_queries version) (icl_chain_trace q) (icl_chain_le q le) (icl_water_memory q).
Proof.
  intros version entry mb nb fb cb e le q Hwall Hfloor Hceil Hwater Hfb Hcb Hnext.
  assert (icqp_queries version = [icl_wall_stage version false; icl_wall_stage version true;
    isfq_query version; icl_ceil_stage version; icl_water_stage version]) as Hshape
    by (destruct version; reflexivity).
  rewrite Hshape. unfold icl_chain_trace, icl_chain_le.
  eapply iap_chain_cons.
  - eapply icl_wall_stage_executes; [exact Hwall|exact Hnext|exact (icl_lower_run q)].
  - eapply iap_chain_cons.
    + eapply icl_wall_stage_executes; [exact Hwall| |exact (icl_upper_run q)].
      unfold icl_wall_le, icl_wall_local, icl_wall_temp.
      repeat rewrite PTree.gso by discriminate. exact Hnext.
    + eapply iap_chain_cons.
      * eapply icl_floor_stage_executes; [exact Hfloor|exact Hfb| |exact (icl_floor_x q)|
          exact (icl_floor_y q)|exact (icl_floor_z q)|exact (icl_floor_run q)].
        unfold icl_wall_le, icl_wall_local, icl_wall_temp.
        repeat rewrite PTree.gso by discriminate. exact Hnext.
      * eapply iap_chain_cons.
        -- eapply icl_ceil_stage_executes; [exact Hceil|exact Hcb| | |exact (icl_ceil_run q)].
           ++ unfold icl_floor_le, icl_wall_le, icl_wall_local, icl_wall_temp.
              repeat rewrite PTree.gso by discriminate. exact Hnext.
           ++ unfold icl_floor_le. apply PTree.gss.
        -- eapply iap_chain_cons.
           ++ eapply icl_water_stage_executes; [exact Hwater| |exact (icl_water_read_x q)|
                exact (icl_water_read_z q)|exact (icl_water_run q)].
              unfold icl_ceil_le, icl_floor_le, icl_wall_le, icl_wall_local, icl_wall_temp.
              repeat rewrite PTree.gso by discriminate. exact Hnext.
           ++ constructor.
Qed.

Lemma icl_water_really_preserves_memory : forall version entry mb nb fb cb
    (q : InkCrawlLiveQueryChain version entry mb nb fb cb),
  icl_water_trace q = E0 /\ icl_water_memory q = icl_ceil_memory q.
Proof.
  intros. eapply thi_complete_call_preserves_memory. exact (icl_water_run q).
Qed.

Lemma icl_floor_really_preserves_state : forall version entry mb nb fb cb
    (q : InkCrawlLiveQueryChain version entry mb nb fb cb),
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_object_list_processor._gMarioStates = Some mb ->
  fb <> mb -> Mem.load Mint32 entry mb 12 = Some (Vint icqp_crawling) ->
  icl_state_frame mb (icl_upper_memory q) (icl_floor_memory q).
Proof.
  intros version entry mb nb fb cb q Hsymbol Hfb Haction.
  assert (Mem.load Mint32 (icl_upper_memory q) mb 12 = Some (Vint icqp_crawling)) as Hupper.
  { rewrite (icl_upper_state_frame q) by (left; reflexivity).
    rewrite (icl_lower_state_frame q) by (left; reflexivity). exact Haction. }
  assert (Mem.valid_block (icl_upper_memory q) mb) as Hvalid
    by (eapply ibcc_loaded_block_valid; exact Hupper).
  intros chunk ofs Hin. eapply (proj2 (ifc_completed_floor_preserves_other_cells
    version (icl_upper_memory q) _ _ _ fb Ptrofs.zero (icl_floor_trace q)
    (icl_floor_memory q) (Vsingle (icqh_f32 1280)) chunk mb ofs Hvalid
    ltac:(intros id Hid Hsame;
      assert (us_object_list_processor._gMarioStates <> id) as Hids by
        (destruct Hid as [<-|[<-|[<-|[]]]]; discriminate);
      assert (mb <> mb) as Hbad by (eapply Genv.global_addresses_distinct; eauto);
      exact (Hbad eq_refl))
    ltac:(left; congruence) (icl_floor_run q))).
Qed.

Theorem icl_live_prefix_preserves_initial_cache : forall version entry mb nb fb cb
    (q : InkCrawlLiveQueryChain version entry mb nb fb cb),
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_object_list_processor._gMarioStates = Some mb ->
  fb <> mb -> Mem.load Mint32 entry mb 12 = Some (Vint icqp_crawling) ->
  icl_state_frame mb entry (icl_water_memory q).
Proof.
  intros version entry mb nb fb cb q Hsymbol Hfb Haction chunk ofs Hin.
  rewrite (proj2 (icl_water_really_preserves_memory _ _ _ _ _ _ q)).
  rewrite (icl_ceil_state_frame q) by exact Hin.
  rewrite (icl_floor_really_preserves_state _ _ _ _ _ _ q Hsymbol Hfb Haction) by exact Hin.
  rewrite (icl_upper_state_frame q), (icl_lower_state_frame q) by exact Hin. reflexivity.
Qed.

Theorem icl_query_cut_is_derived : forall version entry mb nb fb cb e le
    (q : InkCrawlLiveQueryChain version entry mb nb fb cb),
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_object_list_processor._gMarioStates = Some mb ->
  le ! IFH._m = Some (Vptr mb Ptrofs.zero) ->
  le ! IFH._nextPos = Some (Vptr nb Ptrofs.zero) ->
  e ! IFH._floor = Some (fb, icqp_surface) -> fb <> mb -> nb <> mb ->
  Mem.load Mint32 entry mb 12 = Some (Vint icqp_crawling) ->
  InkCrawl973QueryCut version e (icl_chain_le q le) (icl_water_memory q)
    mb nb Ptrofs.zero fb (icl_surface_block q) (icl_surface_offset q)
    icqp_crawling (icl_upper_result q).
Proof.
  intros version entry mb nb fb cb e le q Hsymbol Hm Hnext Hfloor Hfb Hnb Haction.
  pose proof (proj2 (icl_water_really_preserves_memory _ _ _ _ _ _ q)) as Hwater.
  constructor.
  - unfold icl_chain_le, icl_water_le, icl_ceil_le, icl_floor_le,
      icl_wall_le, icl_wall_local, icl_wall_temp.
    repeat rewrite PTree.gso by discriminate. exact Hm.
  - unfold icl_chain_le, icl_water_le, icl_ceil_le, icl_floor_le,
      icl_wall_le, icl_wall_local, icl_wall_temp.
    repeat rewrite PTree.gso by discriminate. exact Hnext.
  - unfold icl_chain_le, icl_water_le, icl_ceil_le, icl_floor_le,
      icl_wall_le, icl_wall_local, icl_wall_temp.
    repeat rewrite PTree.gso by discriminate. apply PTree.gss.
  - exact (icl_upper_is_pointer q).
  - unfold icl_chain_le, icl_water_le, icl_ceil_le, icl_floor_le.
    repeat rewrite PTree.gso by discriminate. apply PTree.gss.
  - unfold icl_chain_le, icl_water_le, icl_ceil_le.
    repeat rewrite PTree.gso by discriminate. apply PTree.gss.
  - exact Hfloor.
  - rewrite Hwater, (icl_ceil_preserves_floor_output q). exact (icl_floor_pointer q).
  - rewrite Hwater. exact (icl_live_surface q).
  - rewrite (icl_live_prefix_preserves_initial_cache _ _ _ _ _ _ q Hsymbol Hfb Haction)
      by (left; reflexivity). exact Haction.
  - exact (proj2 icqp_crawling_source_and_flag).
  - rewrite Hwater. exact (icl_ceil_intended_y q).
  - exact Hfb.
  - exact Hnb.
  - rewrite Hwater. exact (icl_wall_writable q).
Qed.

Lemma icl_actual_entry_query_names : forall version ge start mb nb e le entry,
  function_entry2 ge (ifh_quarter_body version)
    [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero] start e le entry ->
  e ! IFH._resolve_and_return_wall_collisions = None /\
  e ! IFH._find_floor = None /\ e ! IFH._vec3f_find_ceil = None /\
  e ! IFH._find_water_level = None.
Proof.
  intros version ge start mb nb e le entry Hentry.
  assert (fn_vars (ifh_quarter_body version) =
    [(IFH._ceil, icqp_surface); (IFH._floor, icqp_surface)]) as Hvars
    by (destruct version; reflexivity).
  inversion Hentry; subst.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  repeat match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; clear Ha end.
  repeat split; repeat rewrite PTree.gso by discriminate; apply PTree.gempty.
Qed.

Lemma icl_actual_entry_preserves_state : forall version ge start mb nb e le entry,
  Mem.valid_block start mb ->
  function_entry2 ge (ifh_quarter_body version)
    [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero] start e le entry ->
  icl_state_frame mb start entry.
Proof.
  intros version ge start mb nb e le entry Hvalid Hentry.
  inversion Hentry; subst.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    destruct (ipw_alloc_frame _ _ _ _ _ _ Ha mb Hvalid
      ltac:(intros id b ty Hread; rewrite PTree.gempty in Hread; discriminate))
      as (_ & Hframe & _) end.
  intros chunk ofs Hin. apply Hframe.
Qed.

Lemma icl_state_cells_outside_wall : forall chunk ofs,
  In (chunk,ofs) icl_state_cells -> ofs + size_chunk chunk <= 96 \/ 100 <= ofs.
Proof.
  intros chunk ofs H. cbn [icl_state_cells] in H.
  destruct H as [H|[H|[H|[H|[H|[H|[]]]]]]]; inversion H; subst; cbn; lia.
Qed.

(** The initial action/cache belongs to the same pre-entry memory as the
    real quarter call. Actual fresh-local allocation, the five calls and
    their expression/assignment wrappers lead to the real caller break.
    No post-query action/cache/local-floor-height is supplied independently.
    The two wall and ceiling finite-cell effects in q are still obligations;
    the live geometry results and caller coordinate preparation are not proved. *)
Definition InkCrawlLiveQueriesToCaller : Prop :=
  forall version start mb nb caller_e caller_le e entry_le entry fb cb
    (q : InkCrawlLiveQueryChain version entry mb nb fb cb) written returned,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_object_list_processor._gMarioStates = Some mb ->
  nb <> mb -> caller_e ! IFR._perform_ground_quarter_step = None ->
  caller_e ! IFR._intendedPos = Some (nb, tarray tfloat 3) ->
  caller_le ! IFR._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mint32 start mb 12 = Some (Vint icqp_crawling) ->
  function_entry2 (Clight.globalenv (selected_clight_target version))
    (ifh_quarter_body version) [Vptr mb Ptrofs.zero; Vptr nb Ptrofs.zero]
    start e entry_le entry ->
  e ! IFH._floor = Some (fb, icqp_surface) -> e ! IFH._ceil = Some (cb, icqp_surface) ->
  Mem.store Mint32 (icl_water_memory q) mb 96 (icl_upper_result q) = Some written ->
  Mem.free_list written (blocks_of_env
    (Clight.globalenv (selected_clight_target version)) e) = Some returned ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) caller_e caller_le start
    (icqp_caller_tail version) (icl_chain_trace q) (icqp_caller_last caller_le) returned Out_break /\
  icl_state_frame mb start returned.

Theorem icl_live_queries_to_caller_break : InkCrawlLiveQueriesToCaller.
Proof.
  intros version start mb nb caller_e caller_le e entry_le entry fb cb q written returned
    Hsymbol Hnb Hglobal Hvector Hcaller Haction Hentry Hfloor Hceil Hstore Hfree.
  assert (Mem.valid_block start mb) as Hvalid by (eapply ibcc_loaded_block_valid; exact Haction).
  pose proof (icl_actual_entry_preserves_state version _ start mb nb e entry_le entry Hvalid Hentry)
    as HentryFrame.
  assert (Mem.load Mint32 entry mb 12 = Some (Vint icqp_crawling)) as HentryAction
    by (rewrite HentryFrame by (left; reflexivity); exact Haction).
  assert (fb <> mb) as Hfb by
    (eapply icqp_real_entry_has_separate_floor; [exact Hvalid|exact Hentry|exact Hfloor]).
  destruct (icl_actual_entry_query_names _ _ _ _ _ _ _ _ Hentry)
    as (HwallName & HfloorName & HceilName & HwaterName).
  destruct (ifh_quarter_entry_arguments _ _ _ _ _ _ _ _ _ _ Hentry) as (Hm & Hnext & _).
  pose proof (icl_five_real_calls_construct_prefix version entry mb nb fb cb e entry_le q
    HwallName HfloorName HceilName HwaterName Hfloor Hceil Hnext) as Hprefix.
  pose proof (icl_query_cut_is_derived version entry mb nb fb cb e entry_le q
    Hsymbol Hm Hnext Hfloor Hfb Hnb HentryAction) as Hcut.
  destruct (icqp_queries_to_caller_break_and_frame version caller_e caller_le start mb nb e
    entry_le entry (icl_chain_le q entry_le) (icl_water_memory q) (icl_chain_trace q)
    fb (icl_surface_block q) (icl_surface_offset q) icqp_crawling (icl_upper_result q)
    written returned Hvalid Hglobal Hvector Hcaller Hentry Hprefix Hcut Hstore Hfree)
    as [Hrun HreturnFrame].
  split; [exact Hrun|]. intros chunk ofs Hin.
  rewrite HreturnFrame by (apply icl_state_cells_outside_wall; exact Hin).
  rewrite (icl_live_prefix_preserves_initial_cache _ _ _ _ _ _ q Hsymbol Hfb HentryAction)
    by exact Hin. apply HentryFrame. exact Hin.
Qed.

Definition InkCrawlLiveQueriesBoundary := InkCrawlLiveQueriesToCaller.
Theorem icl_crawl_live_queries_checked : InkCrawlLiveQueriesBoundary.
Proof. exact icl_live_queries_to_caller_break. Qed.
