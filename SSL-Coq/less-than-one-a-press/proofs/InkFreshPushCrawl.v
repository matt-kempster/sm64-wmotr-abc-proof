(** Conditional composition of named generated cuts, with shared memories.
    The two intervening paths are actual Clight2 steps, with four explicitly
    protected cells. They are NOT proved to stay in one Mario-action activation.
    Their continuations, effects, and activation membership remain obligations.
    No initial numeric floor cache, live item, timer, or no-A route is supplied
    or concluded by this module. *)
From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Ctypes
  Events Floats Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import us_object_list_processor.
From LessThanOneAPress.Proofs Require Import GameTypes InkObjectPushQuery
  InkObjectPushHandoff InkFloorHistorySource InkFloorHistoryQuery
  InkBackwardSource InkActionPassHistory InkGroundBackwardSource
  InkFloorResetSource InkCrawlQuarterHandoff InkCrawlQuarterPrefix
  InkCrawlLiveQueries ObjectContactNecessity UpperElevatorQueryResolution
  SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

(** Exactly four cell effects, not a whole-memory or whole-update frame. *)
Definition ifpc_interval_frame mb before after : Prop :=
  Mem.load Mint32 after mb 12 = Mem.load Mint32 before mb 12 /\
  Mem.load Mfloat32 after mb 64 = Mem.load Mfloat32 before mb 64 /\
  Mem.load Mint32 after mb 104 = Mem.load Mint32 before mb 104 /\
  Mem.load Mfloat32 after mb 112 = Mem.load Mfloat32 before mb 112.

Set Implicit Arguments.
Record InkFreshPushCrawlCuts (version : GameVersion) (mb : block) : Type := {
  ifpc_initial_memory : mem;
  ifpc_geometry_env : env;
  ifpc_geometry_initial : temp_env;
  ifpc_geometry_last : temp_env;
  ifpc_geometry_cont : cont;
  ifpc_primary_trace : trace;
  ifpc_fresh_memory : mem;
  ifpc_symbol : Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_object_list_processor._gMarioStates = Some mb;
  ifpc_geometry_global : ifpc_geometry_env ! IBM._find_floor = None;
  ifpc_geometry_mario : ifpc_geometry_initial ! IBM._m = Some (Vptr mb Ptrofs.zero);
  ifpc_initial_y : Mem.load Mfloat32 ifpc_initial_memory mb 64 =
    Some (Vsingle (icqh_f32 1741));
  ifpc_initial_action : Mem.load Mint32 ifpc_initial_memory mb 12 = Some (Vint icqp_crawling);
  ifpc_primary_run : ocn_exec (Clight.globalenv (selected_clight_target version))
    ifpc_geometry_env ifpc_geometry_initial ifpc_initial_memory
    (ifh_geometry_query version) ifpc_primary_trace ifpc_geometry_last ifpc_fresh_memory Out_normal;

  ifpc_push_memory : mem;
  ifpc_push_env : env;
  ifpc_push_initial : temp_env;
  ifpc_push_last : temp_env;
  ifpc_push_cont : cont;
  ifpc_push_floor : block;
  ifpc_push_global : ifpc_push_env ! IPH._find_floor = None;
  ifpc_push_local : ifpc_push_env ! IPH._floor = Some (ifpc_push_floor, ipq_surface);
  ifpc_push_separate : mb <> ifpc_push_floor;
  ifpc_push_mario : ifpc_push_initial ! IPH._m = Some (Vptr mb Ptrofs.zero);
  ifpc_before_push_trace : trace;
  ifpc_before_push_run : star Clight.step2 (Clight.globalenv (selected_clight_target version))
    (State (ibk_geometry_body version) (ifh_geometry_after_query version)
      ifpc_geometry_cont ifpc_geometry_env ifpc_geometry_last ifpc_fresh_memory)
    ifpc_before_push_trace
    (State (iph_body version) (ipq_after_wall version)
      ifpc_push_cont ifpc_push_env ifpc_push_initial ifpc_push_memory);
  ifpc_before_push_frame : ifpc_interval_frame mb ifpc_fresh_memory ifpc_push_memory;
  ifpc_push_trace : trace;
  ifpc_pushed_memory : mem;
  ifpc_push_run : ocn_exec (Clight.globalenv (selected_clight_target version))
    ifpc_push_env ifpc_push_initial ifpc_push_memory (ipq_after_wall version)
    ifpc_push_trace ifpc_push_last ifpc_pushed_memory Out_normal;

  ifpc_crawl_memory : mem;
  ifpc_caller_env : env;
  ifpc_caller_initial : temp_env;
  ifpc_caller_cont : cont;
  ifpc_after_push_trace : trace;
  ifpc_after_push_run : star Clight.step2 (Clight.globalenv (selected_clight_target version))
    (State (iph_body version) Sskip ifpc_push_cont
      ifpc_push_env ifpc_push_last ifpc_pushed_memory)
    ifpc_after_push_trace
    (State (igb_body version) (icqp_caller_tail version) ifpc_caller_cont
      ifpc_caller_env ifpc_caller_initial ifpc_crawl_memory);
  ifpc_after_push_frame : ifpc_interval_frame mb ifpc_pushed_memory ifpc_crawl_memory;
  ifpc_intended : block;
  ifpc_intended_separate : ifpc_intended <> mb;
  ifpc_caller_global : ifpc_caller_env ! IFR._perform_ground_quarter_step = None;
  ifpc_caller_vector : ifpc_caller_env ! IFR._intendedPos = Some (ifpc_intended, tarray tfloat 3);
  ifpc_caller_mario : ifpc_caller_initial ! IFR._m = Some (Vptr mb Ptrofs.zero);
  ifpc_quarter_env : env;
  ifpc_quarter_initial : temp_env;
  ifpc_entry_memory : mem;
  ifpc_quarter_entry : function_entry2 (Clight.globalenv (selected_clight_target version))
    (ifh_quarter_body version) [Vptr mb Ptrofs.zero; Vptr ifpc_intended Ptrofs.zero]
    ifpc_crawl_memory ifpc_quarter_env ifpc_quarter_initial ifpc_entry_memory;
  ifpc_floor : block;
  ifpc_ceiling : block;
  ifpc_floor_local : ifpc_quarter_env ! IFH._floor = Some (ifpc_floor, icqp_surface);
  ifpc_ceiling_local : ifpc_quarter_env ! IFH._ceil = Some (ifpc_ceiling, icqp_surface);
  ifpc_queries : InkCrawlLiveQueryChain version ifpc_entry_memory mb ifpc_intended ifpc_floor ifpc_ceiling;
  ifpc_written_memory : mem;
  ifpc_returned_memory : mem;
  ifpc_wall_store : Mem.store Mint32 (icl_water_memory ifpc_queries) mb 96
    (icl_upper_result ifpc_queries) = Some ifpc_written_memory;
  ifpc_quarter_free : Mem.free_list ifpc_written_memory
    (blocks_of_env (Clight.globalenv (selected_clight_target version)) ifpc_quarter_env) =
    Some ifpc_returned_memory
}.
Unset Implicit Arguments.

Definition ifpc_trace {version mb} (r : InkFreshPushCrawlCuts version mb) :=
  ifpc_primary_trace r ++ (ifpc_before_push_trace r ++
    (ifpc_push_trace r ++ (ifpc_after_push_trace r ++ icl_chain_trace (ifpc_queries r)))).
Definition ifpc_first {version mb} (r : InkFreshPushCrawlCuts version mb) :=
  State (ibk_geometry_body version) (ifh_geometry_query version)
    (Kseq (ifh_geometry_after_query version) (ifpc_geometry_cont r))
    (ifpc_geometry_env r) (ifpc_geometry_initial r) (ifpc_initial_memory r).
Definition ifpc_last {version mb} (r : InkFreshPushCrawlCuts version mb) :=
  State (igb_body version) Sbreak (ifpc_caller_cont r) (ifpc_caller_env r)
    (icqp_caller_last (ifpc_caller_initial r)) (ifpc_returned_memory r).

Lemma ifpc_primary_steps : forall version e le before trace last fresh k,
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (ifh_geometry_query version) trace last fresh Out_normal ->
  star Clight.step2 (Clight.globalenv (selected_clight_target version))
    (State (ibk_geometry_body version) (ifh_geometry_query version)
      (Kseq (ifh_geometry_after_query version) k) e le before) trace
    (State (ibk_geometry_body version) (ifh_geometry_after_query version) k e last fresh).
Proof.
  intros version e le before trace last fresh k Hrun.
  eapply star_trans.
  - eapply iap_normal_statement_steps; exact Hrun.
  - apply star_one. apply step_skip_seq.
  - unfold Eapp, E0. rewrite app_nil_r. reflexivity.
Qed.

Lemma ifpc_break_steps : forall program e le before s trace last after,
  ocn_exec (Clight.globalenv program) e le before s trace last after Out_break ->
  forall f k, star Clight.step2 (Clight.globalenv program)
    (State f s k e le before) trace (State f Sbreak k e last after).
Proof.
  intros program e le before s trace last after Hrun f k.
  destruct (ClightBigstep.exec_stmt_steps Clight.function_entry2 program
    e le before s trace last after Out_break Hrun f k) as (final & Hsteps & Hout).
  inversion Hout; subst. exact Hsteps.
Qed.

Definition InkFreshPushCrawlComposition : Prop :=
  forall version mb (r : InkFreshPushCrawlCuts version mb),
  exists x z floor queried,
    ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version))
      (ifpc_initial_memory r) (Internal (ueqr_native_body version UEQRFindFloor))
      [Vsingle x; Vsingle (icqh_f32 1741); Vsingle z; Vptr mb (Ptrofs.repr 104)]
      E0 queried (Vsingle floor) /\
    Mem.store Mfloat32 queried mb 112 (Vsingle floor) = Some (ifpc_fresh_memory r) /\
    Mem.load Mfloat32 (ifpc_returned_memory r) mb 64 = Some (Vsingle (icqh_f32 1741)) /\
    Mem.load Mint32 (ifpc_returned_memory r) mb 12 = Some (Vint icqp_crawling) /\
    Mem.load Mint32 (ifpc_returned_memory r) mb 104 = Mem.load Mint32 queried mb 104 /\
    Mem.load Mfloat32 (ifpc_returned_memory r) mb 112 = Some (Vsingle floor) /\
    (Mem.load Mfloat32 (ifpc_returned_memory r) mb 112 = Some (Vsingle (icqh_f32 768))
      <-> floor = icqh_f32 768) /\
    star Clight.step2 (Clight.globalenv (selected_clight_target version))
      (ifpc_first r) (ifpc_trace r) (ifpc_last r).

Theorem ifpc_named_cuts_compose_with_fresh_cache : InkFreshPushCrawlComposition.
Proof.
  intros version mb r.
  destruct (ipq_primary_query_supplies_fresh_cache version (ifpc_geometry_env r)
    (ifpc_geometry_initial r) (ifpc_initial_memory r) mb (icqh_f32 1741)
    (ifpc_primary_trace r) (ifpc_geometry_last r) (ifpc_fresh_memory r) Out_normal
    (ifpc_geometry_global r) (ifpc_symbol r) (ifpc_geometry_mario r)
    (ifpc_initial_y r) (ifpc_primary_run r))
    as (x & z & floor & queried & Hcall & Hstore & HfreshCache & HfreshPointer & HfreshAction & HfreshY).
  destruct (ifpc_before_push_frame r) as (Baction & By & Bpointer & Bcache).
  destruct (ifpc_after_push_frame r) as (Aaction & Ay & Apointer & Acache).
  assert (Mem.load Mfloat32 (ifpc_push_memory r) mb 64 = Some (Vsingle (icqh_f32 1741))) as HpushY
    by (rewrite By; exact HfreshY).
  destruct (ipq_destination_query_and_commit_preserve_cache version (ifpc_push_env r)
    (ifpc_push_initial r) (ifpc_push_memory r) mb (ifpc_push_floor r) (icqh_f32 1741)
    (ifpc_push_trace r) (ifpc_push_last r) (ifpc_pushed_memory r) Out_normal
    (ifpc_push_global r) (ifpc_push_local r) (ifpc_symbol r) (ifpc_push_separate r)
    (ifpc_push_mario r) HpushY (ifpc_push_run r)) as (Py & Ppointer & Pcache & Paction).
  assert (Mem.load Mint32 (ifpc_crawl_memory r) mb 12 = Some (Vint icqp_crawling)) as HcrawlAction.
  { rewrite Aaction, Paction, Baction, HfreshAction. exact (ifpc_initial_action r). }
  destruct (icl_live_queries_to_caller_break version (ifpc_crawl_memory r) mb (ifpc_intended r)
    (ifpc_caller_env r) (ifpc_caller_initial r) (ifpc_quarter_env r) (ifpc_quarter_initial r)
    (ifpc_entry_memory r) (ifpc_floor r) (ifpc_ceiling r) (ifpc_queries r)
    (ifpc_written_memory r) (ifpc_returned_memory r) (ifpc_symbol r)
    (ifpc_intended_separate r) (ifpc_caller_global r) (ifpc_caller_vector r)
    (ifpc_caller_mario r) HcrawlAction (ifpc_quarter_entry r) (ifpc_floor_local r)
    (ifpc_ceiling_local r) (ifpc_wall_store r) (ifpc_quarter_free r)) as (Hcrawl & Hframe).
  assert (Mem.load Mfloat32 (ifpc_returned_memory r) mb 112 = Some (Vsingle floor)) as HfinalCache.
  { rewrite Hframe by (unfold icl_state_cells; right; right; right; right; right; left; reflexivity).
    rewrite Acache, Pcache, Bcache. exact HfreshCache. }
  exists x, z, floor, queried. split; [exact Hcall|]. split; [exact Hstore|].
  split.
  - rewrite Hframe by (unfold icl_state_cells; right; right; left; reflexivity). rewrite Ay. exact Py.
  - split.
    + rewrite Hframe by (unfold icl_state_cells; left; reflexivity). exact HcrawlAction.
    + split.
      * rewrite Hframe by (unfold icl_state_cells; right; right; right; right; left; reflexivity).
        rewrite Apointer, Ppointer, Bpointer. exact HfreshPointer.
      * split; [exact HfinalCache|]. split.
        -- rewrite HfinalCache. split; intro H; [inversion H; subst; reflexivity|now subst].
        -- unfold ifpc_first, ifpc_last, ifpc_trace.
           eapply star_trans; [eapply ifpc_primary_steps; exact (ifpc_primary_run r)| |reflexivity].
           eapply star_trans; [exact (ifpc_before_push_run r)| |reflexivity].
           eapply star_trans; [eapply iap_normal_statement_steps; exact (ifpc_push_run r)| |reflexivity].
           eapply star_trans; [exact (ifpc_after_push_run r)| |reflexivity].
           eapply ifpc_break_steps. exact Hcrawl.
Qed.

Definition InkFreshPushCrawlBoundary := InkFreshPushCrawlComposition.
Theorem ifpc_fresh_push_crawl_checked : InkFreshPushCrawlBoundary.
Proof. exact ifpc_named_cuts_compose_with_fresh_cache. Qed.
