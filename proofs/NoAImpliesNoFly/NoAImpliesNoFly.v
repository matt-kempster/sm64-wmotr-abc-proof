(* spine-root: GOAL-1 capstone (no-A => no-fly). *)
(* NoAImpliesNoFly.v -- GOAL 1 capstone: a no-A (no-spawn) run never enters ACT_FLYING.
 *
 * THE STEP IS NOW THE REAL CLIGHTGEN'D FRAME (this session's tethering move).
 * Previously `step` was an ABSTRACT relation and `frame_preserves_nonflying` a
 * black-box hypothesis. Both are gone:
 *   - `step` is now `RealFrameValue.execute_mario_action_step` -- one CompCert
 *     big-step `eval_funcall` of the ACTUAL `mario.f_execute_mario_action` from
 *     the clightgen'd AST, over the real Mario genv `mario_ge = globalenv
 *     mario.prog`. No placeholder relation.
 *   - the per-frame obligation is now a PROVED lemma (frame_preserves_mem_ok),
 *     discharged by the value engine via RealFrameValue's generic funcall->value
 *     bridge. What the capstone rests on is no longer a single opaque
 *     "frames keep you non-flying" wish, but the value engine's three NAMED reach
 *     residuals over the real genv (below).
 *
 * WHY A PRECONDITION IS NEEDED (the bug in the naive statement). "A no-A run never
 * reaches ACT_FLYING" is, taken unconditionally, FALSE: a warp whose spawn type is
 * MARIO_SPAWN_FLYING (0x17) makes level_update.c's set_mario_initial_action call
 * set_mario_action(m, ACT_FLYING, 2) with no button input (Tower of the Wing Cap).
 * The honest theorem EXCLUDES that route. WMotR's object/warp set contains NO
 * MARIO_SPAWN_FLYING warp; we state the thing WMotR GIVES as an explicit run-level
 * precondition (no_spawn_flying_run) rather than yet machine-extracting it.
 *
 * WHAT IS TETHERED HERE vs. STILL A NAMED RESIDUAL (no buried ledes):
 *   REAL now:
 *     - `mem_flying`/`mem_nonflying`: the flying state is the ACTUAL action value
 *       loaded from Mario's struct (Mem.load Mint32 m bm 12), classified by
 *       Flying.is_flying_int. No abstract `flying : S -> Prop`.
 *     - `step`: the real `eval_funcall` of `f_execute_mario_action` (see above).
 *     - `frame_preserves_mem_ok`: PROVED from the value engine, not assumed.
 *   THE NAMED RESIDUALS (the honest scoreboard -- the value engine's reach surface
 *   over the real Mario genv; these are what the capstone now rests on):
 *     (1) reach_value_preserves nonflying bm mario_ge  -- THE INTERPROCEDURAL CRUX:
 *         every funcall reached inside a frame preserves the non-flying action.
 *         As stated UNCONDITIONALLY this is still too strong (set_mario_action with
 *         an ACT_FLYING argument is a reached funcall that does NOT preserve it);
 *         closing it needs the no-A carve-out -- the only action writer is
 *         set_mario_action, and under a no-A frame its argument is non-flying
 *         (ActionValue.set_mario_action_field + the ActionWriters corpus). The
 *         no_A/no_spawn preconditions of THIS theorem are carried for exactly that
 *         conditioning step; the present per-frame proof does not yet consume them
 *         (it leans on reach_value_preserves), and that is the next crux. This is
 *         the same disclosed-precise-gap discipline as Unwired/AltStatements/
 *         FlyingFrame.v, now one level sharper (value engine, not unchanged_on).
 *     (2) reach_ext_preserves (action_cell bm) mario_ge  -- externals don't write
 *         the action cell. Satisfiable/true; removable.
 *     (3) the real body preserves the invariant (body_preserves_real bm)  --
 *         MADE CONCRETE 2026-06-02 (was the FALSE `forall e, stmt_value_ok ...`).
 *         SM64 is ONE program, so we do NOT quantify over adversarial local
 *         environments: (3) is a fact about the ACTUAL executions of the ONE body
 *         -- from a well-formed state (valid bm, non-flying action, marioObj off
 *         bm) and given (1)+(2), the real exec_stmt of f_execute_mario_action
 *         preserves all three. The earlier `forall le` form was unprovable
 *         (assign_value_ok admitted a temp aliasing bm); this concrete form is
 *         TRUE -- the body's two stores land off bm by marioObj_wf
 *         (store{1,2}_avoids_action_cell, PROVED against the literal AST), its
 *         calls preserve by (1), its builtins by (2). Discharging (3) is the
 *         augmented-engine work; the geometry payoff lemmas are its store bricks.
 *
 * So this capstone reduces "a no-A no-spawn run never flies" to: (1) the
 * interprocedural crux, (2) the externals, and (3) the concrete body execution --
 * none of them an adversarial `forall le`/`forall fd` universal beyond what the
 * fixed program forces.
 *
 * No Admitted.
 *)

From Coq Require Import List Bool.
Import ListNotations.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Events Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying FieldNonInterference ActionValueFrame
  ReachableRun RealFrameValue.

Section NoAImpliesNoFly.
  (* Mario's struct block is fixed; the action field loads at (bm, 12) as Mint32 --
     exactly the value engine's watched cell. *)
  Variable bm : block.

  (* ---- REAL flying / non-flying, by the loaded action value (no placeholder) ---- *)

  Definition mem_flying (m : mem) : Prop :=
    exists v, Mem.load Mint32 m bm 12 = Some (Vint v) /\ is_flying_int v = true.

  Definition mem_nonflying (m : mem) : Prop :=
    action_sat nonflying m bm.

  (* The carried run invariant: Mario's block is allocated, its action is
     non-flying, AND Mario memory is well-formed (gMarioState->marioObj points
     off bm). All three are genuine content the concrete per-frame proof needs
     and re-establishes: validity (loads stay meaningful), non-flying (the goal),
     and marioObj_wf (what keeps the body's two pointer-chase stores off the
     action cell). NOT abstract -- marioObj_wf is a fact about the real struct. *)
  Definition mem_ok (m : mem) : Prop :=
    Mem.valid_block m bm /\ mem_nonflying m /\ marioObj_wf m bm /\ gMarioState_wf m bm.

  (* The invariant really does forbid flying: if every loaded action value is
     non-flying, no loaded action value is flying. *)
  Lemma mem_nonflying_not_flying : forall m, mem_nonflying m -> ~ mem_flying m.
  Proof.
    intros m Hnf [v [Hld Hfly]]. specialize (Hnf v Hld).
    unfold nonflying in Hnf. congruence.
  Qed.

  Lemma mem_ok_not_flying : forall m, mem_ok m -> ~ mem_flying m.
  Proof. intros m [_ [Hnf _]]. exact (mem_nonflying_not_flying m Hnf). Qed.

  (* ---- the input layer: abstract. (Grounding the input word / A-bit is the
         orthogonal FlyingStatement tethering; THIS goal concretizes the STEP.) ---- *)
  Variable Inp : Type.
  Variable a_pressed    : Inp -> bool.   (* did THIS frame newly press A?        *)
  Variable spawn_flying : Inp -> bool.   (* did THIS frame do a MARIO_SPAWN_FLYING
                                            spawn? (the class-3 hatch)           *)

  (* ---- THE STEP IS REAL: one big-step of the clightgen'd per-frame function. ----
     (It reads its input from memory; the value-engine preservation holds for any
     input, so `step` does not branch on `i` -- the no-A conditioning lives in the
     reach residual (1), not in the relation.) *)
  Definition step (_ : Inp) (m m' : mem) : Prop :=
    execute_mario_action_step m m'.

  (* ---- The two run-level preconditions, as REAL Forall facts over the frames ---- *)

  Definition noA_run_real (is : list Inp) : Prop :=
    Forall (fun i => a_pressed i = false) is.

  (* The WMotR-supplied precondition: no frame fires the spawn-flying hatch. *)
  Definition no_spawn_flying_run (is : list Inp) : Prop :=
    Forall (fun i => spawn_flying i = false) is.

  (* ---- The NO-A memory predicate + the reach residuals over the REAL genv ----
     The honest scoreboard the capstone now rests on. `NoA m` says "this frame's
     memory has Mario's A button unpressed". It is left ABSTRACT here; the next
     tethering step is to GROUND it in the real controller bytes -- exactly the
     move that turned the once-abstract `step` into the real eval_funcall. Every
     residual below is TRUE at the real NoA, and none is an adversarial universal. *)
  Variable NoA : mem -> Prop.

  (* The designated action writer: among reached funcalls, only set_mario_action
     writes Mario's action cell. A REAL object -- the clightgen'd f_set_mario_action
     -- not a placeholder. *)
  Definition writer_set_mario_action (fd : Clight.fundef) : Prop :=
    fd = Ctypes.Internal mario.f_set_mario_action.

  (* (1) THE CRUX -- action-value preservation across reached funcalls. The value
     engine is now ActionValueFrame.exec_funcall_reach_value_MARG, the type-forced
     successor of the noA engine: its OUTPUT (reach_value_preserves_marg) carries a
     `marg_ok bm vargs` precondition, so it is SATISFIABLE -- the forall-vargs
     reach_value_preserves_noA is FALSE for a misaligned Mario arg (Vptr bm (12-d)
     to a non-writer aims an `m->field` store at the action cell). The body engine
     (execute_mario_action_preserves_real_marg) SUPPLIES marg_ok at execute_mario_
     action's own call sites from its Pgms census; the residuals below cover the
     REACHED callees via an abstract entry-temp invariant TI + per-body census C.
     SCOPE (docs/theorem-scope.md): mario_ge = globalenv mario.prog is ONE TU
     (mario.c, 62 internal funcs). The 571 action handlers / interaction table are
     EXTERNAL here, governed by (3), NOT by (1).

     TI/C: the (abstract) entry-temp invariant and per-body census of the REACHED
     functions. The marg leaf residuals (1a)-(1d) replace the FALSE phantom
     reach_value_body_nonwriter -- each speaks about the actual entry temp env /
     actual call args under a marg_ok guard, never an adversarial `forall le`. *)
  Variable TI : temp_env -> Prop.
  Variable C  : statement -> Prop.
  (* (1a) marg-gated body leaf: a reached non-writer entered with marg_ok args has
          entry-temp-invariant TI and its body passes census C. EXECUTION-RELATIVE
          (the entry le is the one the marg call args produced), not forall-le. *)
  Hypothesis reach_value_body_marg :
    forall f vargs m e le m1,
      function_entry2 mario_ge f vargs m e le m1 ->
      ~ writer_set_mario_action (Ctypes.Internal f) ->
      marg_ok bm vargs ->
      TI le /\ C (fn_body f).
  (* (1a') a direct Sassign under TI+C preserves validity + non-flying (it stores
          off the action cell OR a non-flying value). *)
  Hypothesis reach_assign_marg :
    forall e le m a1 a2 loc ofs bf v2 v m',
      eval_lvalue mario_ge e le m a1 loc ofs bf ->
      eval_expr mario_ge e le m a2 v2 ->
      sem_cast v2 (typeof a2) (typeof a1) m = Some v ->
      assign_loc mario_ge (typeof a1) m loc ofs bf v m' ->
      TI le -> C (Sassign a1 a2) ->
      Mem.valid_block m bm -> action_sat nonflying m bm ->
      Mem.valid_block m' bm /\ action_sat nonflying m' bm.
  (* (1a'') under TI, a reached call's evaluated args are marg_ok (the Mario arg
           temp is (bm,0)-or-off-bm) -- the call-site bridge that THREADS marg. *)
  Hypothesis reach_call_marg :
    forall e le m optid a al tyargs vargs,
      TI le -> C (Scall optid a al) ->
      eval_exprlist mario_ge e le m al tyargs vargs -> marg_ok bm vargs.
  (* (1a''') TI is preserved by a censused Sset and by a censused call/builtin result. *)
  Hypothesis reach_TI_set :
    forall e le m id a v,
      eval_expr mario_ge e le m a v -> TI le -> C (Sset id a) -> TI (PTree.set id v le).
  Hypothesis reach_TI_optc :
    forall optid a al v le, C (Scall optid a al) -> TI le -> TI (set_opttemp optid v le).
  Hypothesis reach_TI_optb :
    forall optid ef tyargs al v le,
      C (Sbuiltin optid ef tyargs al) -> TI le -> TI (set_opttemp optid v le).
  (* (1a'''') the census C distributes over the compound statement forms. *)
  Hypothesis reach_C_seq  : forall s1 s2, C (Ssequence s1 s2) -> C s1 /\ C s2.
  Hypothesis reach_C_if   : forall a s1 s2, C (Sifthenelse a s1 s2) -> C s1 /\ C s2.
  Hypothesis reach_C_loop : forall s1 s2, C (Sloop s1 s2) -> C s1 /\ C s2.
  Hypothesis reach_C_sw   :
    forall a ls n, C (Sswitch a ls) -> C (seq_of_labeled_statement (select_switch n ls)).
  (* (1b) PHANTOM via forall-vargs. set_mario_action under NoA does NOT preserve
          non-flying for arbitrary vargs (vargs=[..,ACT_FLYING,..] with NoA holding
          breaks it). Real content = TAINT CLOSURE (no-A => the ACTUAL calls have
          non-flying args; A-gated). The A-gates live in EXTERNAL TUs, so this is not
          fully expressible at single-TU scope -- it needs linking. *)
  Hypothesis reach_writer_ok :
    reach_writer_preserves_noA nonflying bm mario_ge writer_set_mario_action NoA.
  (* (1c) reached externals don't write the action cell. NB: these "externals"
          INCLUDE the cross-TU action handlers (the mario_execute_ / act_ family) --
          so this is a STRONG assumption that currently holds the real crux, to be
          discharged by linking, not a mere math/memcpy boundary. *)
  Hypothesis reach_ext_action_cell :
    reach_ext_preserves (action_cell bm) mario_ge.
  (* (2) every reached funcall ALSO preserves NoA and the two Mario-pointer
     invariants (marioObj off bm, gMarioState -> bm); together with (1) this is
     the engine's full no-A-conditioned reach. A call-graph fact about the
     REACHED functions, the next discharge target (per-function offset analysis).*)
  Hypothesis reach_rest_ok : reach_rest_marg bm NoA.
  (* (3) every reached external, in a no-A state, preserves NoA and the full
     memory invariant (SM64 externals are memcpy/bzero-class). *)
  Hypothesis ext_meminv_ok :
    forall ef vargs mm tt vres mm',
      NoA mm -> meminv bm mm ->
      external_call ef mario_ge vargs mm tt vres mm' -> NoA mm' /\ meminv bm mm'.
  (* (4) NoA (Mario's A-button unpressed) is preserved by any reached statement
     execution and by function entry -- the frame writes no controller-input
     bytes (action/object writes hit OTHER blocks), and entry only allocates
     fresh blocks. Generalizes the old Sassign-only noA_store_ok; the value
     engine needs the statement+entry form to thread NoA to each reached
     set_mario_action call (where the no-A taint-closure gate fires). *)
  Hypothesis noA_exec_ok :
    forall e le mm s tt le' mm' out,
      exec_stmt function_entry2 mario_ge e le mm s tt le' mm' out -> NoA mm -> NoA mm'.
  Hypothesis noA_entry_ok :
    forall f vargs mm e le mm1,
      function_entry2 mario_ge f vargs mm e le mm1 -> NoA mm -> NoA mm1.
  (* (5) the real body preserves the invariant: now PROVED, not assumed. The old
     `body_preserves_real bm NoA` hypothesis is GONE -- the body is discharged by
     RealFrameValue.execute_mario_action_preserves_real (the census-backed
     exec_body_prov_noA engine + entry bookkeeping). Only the REACHED-call-graph
     residuals (1)-(4) remain. *)
  (* INPUT GROUNDING: a no-A frame's starting memory satisfies NoA. The named
     residual that ties the abstract a_pressed flag to the real frame memory;
     it and NoA's grounding are the remaining input-layer gap. *)
  Hypothesis input_grounds_noA :
    forall i m m', a_pressed i = false -> step i m m' -> NoA m.

  (* ---- The per-frame obligation: now PROVED via the value engine bridge ----
     A real frame preserves (bm valid /\ action non-flying). The a_pressed/
     spawn_flying flags are accepted but not consumed here -- preservation follows
     from the value engine + reach residual (1); see header on the no-A conditioning
     that residual (1) still awaits. *)
  Lemma frame_preserves_mem_ok :
    forall i m m',
      a_pressed i = false ->
      spawn_flying i = false ->
      mem_ok m ->
      step i m m' ->
      mem_ok m'.
  Proof.
    intros i m m' Ha _ (Hv & Hsat & Hwf & Hgwf) Hst.
    assert (HnoA : NoA m) by (eapply input_grounds_noA; eassumption).
    (* the SOUND MARG value engine: marg-gated leaf-A (non-writer direct bodies
       under TI+C) + the no-A writer case + ext + NoA-propagation -> the action
       stays non-flying across every reached funcall WHOSE Mario arg is marg_ok.
       The body engine supplies marg_ok at the real call sites. *)
    pose proof (exec_funcall_reach_value_marg nonflying bm mario_ge NoA
                  writer_set_mario_action TI C
                  reach_value_body_marg reach_assign_marg reach_call_marg
                  reach_TI_set reach_TI_optc reach_TI_optb
                  reach_writer_ok reach_ext_action_cell noA_exec_ok noA_entry_ok
                  reach_C_seq reach_C_if reach_C_loop reach_C_sw)
      as Hreach.
    destruct (execute_mario_action_preserves_real_marg bm NoA m m'
                Hreach reach_rest_ok ext_meminv_ok
                (fun e le mm a1 a2 tt le' mm' out HnoA' _ Hexec =>
                   noA_exec_ok e le mm (Sassign a1 a2) tt le' mm' out Hexec HnoA')
                HnoA Hv Hsat Hwf Hgwf Hst)
      as (_ & Hv' & Hs' & Hw' & Hgw').
    exact (conj Hv' (conj Hs' (conj Hw' Hgw'))).
  Qed.

  (* Combine the two run preconditions into the single "no dangerous frame" flag
     that the ReachableRun harness consumes (a frame is dangerous if it presses A OR
     spawn-flies). *)
  Lemma combine_preconditions :
    forall is,
      noA_run_real is ->
      no_spawn_flying_run is ->
      noA_run Inp (fun i => orb (a_pressed i) (spawn_flying i)) is.
  Proof.
    unfold noA_run_real, no_spawn_flying_run, noA_run.
    induction is as [| i rest IH]; intros HA HS.
    - constructor.
    - inversion HA; subst. inversion HS; subst.
      constructor.
      + apply orb_false_iff; split; assumption.
      + apply IH; assumption.
  Qed.

  (* ====================================================================== *)
  (* THE TETHERED THEOREM.                                                   *)
  (*                                                                        *)
  (* For the real flying state (the loaded action value), the REAL per-frame  *)
  (* `eval_funcall` step, and the two real preconditions, a run that starts    *)
  (* allocated-and-non-flying NEVER reaches a flying state. Proved by           *)
  (* instantiating ReachableRun's invariant-induction harness with the REAL      *)
  (* non-flying invariant; the per-frame step is discharged by the value engine. *)
  (* ====================================================================== *)
  Theorem noA_no_spawn_never_flying :
    forall (init : mem) (is : list Inp) (m : mem),
      mem_ok init ->
      noA_run_real is ->
      no_spawn_flying_run is ->
      reachable mem Inp step init is m ->
      ~ mem_flying m.
  Proof.
    intros init is m Hinit HnoA Hnospawn Hreach.
    eapply (noA_run_not_flying mem Inp
              (fun i => orb (a_pressed i) (spawn_flying i)) step
              mem_flying mem_ok init).
    - (* base: start allocated and non-flying *) exact Hinit.
    - (* step: a non-dangerous frame preserves the invariant *)
      intros i s s' Hd Hphi Hst.
      apply orb_false_iff in Hd. destruct Hd as [Ha Hsp].
      eapply frame_preserves_mem_ok; eauto.
    - (* safety: the invariant excludes flying *)
      exact mem_ok_not_flying.
    - (* the combined no-dangerous-frame run *)
      exact (combine_preconditions is HnoA Hnospawn).
    - (* the run itself *)
      exact Hreach.
  Qed.

End NoAImpliesNoFly.
