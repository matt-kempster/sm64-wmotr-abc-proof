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

From Coq Require Import List Bool PArith.BinPos.
Import ListNotations.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Events Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying FieldNonInterference ActionValueFrame
  ReachableRun RealFrameValue CallgraphReach.

(* ===================================================================== *)
(* THE CONCRETE REACHED SET (no longer abstract). execute_mario_action +  *)
(* its 17 writer-free reachable internal callees, computed from the real  *)
(* clightgen'd static call graph (docs/reachable-internal-graph.md; the   *)
(* sole action writer set_mario_action is NOT among them, machine-checked *)
(* in Unwired/ReachScratch). `reached_id` is the call-target gate the      *)
(* body-engine census reach_chk uses: a direct call is OK iff its target   *)
(* is a reached internal function OR an external symbol (externals handled *)
(* by the external residual). Decidable, so reach_chk(real body) closes by *)
(* computation. *)
(* ===================================================================== *)
Definition reached_ids : list ident :=
  [ mario._execute_mario_action
  ; mario._debug_print_speed_action_normal
  ; mario._mario_floor_is_slippery
  ; mario._mario_get_floor_class
  ; mario._mario_get_terrain_sound_addend
  ; mario._mario_reset_bodystate
  ; mario._mario_update_hitbox_and_cap_model
  ; mario._set_submerged_cam_preset_and_spawn_bubbles
  ; mario._sink_mario_in_quicksand
  ; mario._squish_mario_model
  ; mario._update_and_return_cap_flags
  ; mario._update_mario_button_inputs
  ; mario._update_mario_geometry_inputs
  ; mario._update_mario_health
  ; mario._update_mario_info_for_cam
  ; mario._update_mario_inputs
  ; mario._update_mario_joystick_inputs
  ; mario._vec3f_find_ceil ].

Definition reached_id (id : ident) : Prop :=
  (existsb (Pos.eqb id) reached_ids
   || match func_of mario.prog id with Some _ => false | None => true end) = true.

(* The reached functions as fundefs (the 17 writer-free internals), and the
   fundef-level gate: a funcall is reached iff it is one of these OR an external
   (externals governed by the external residual). The sole action writer
   set_mario_action is NOT among the 17 -- see writer_leaf_vacuous below. *)
Definition reached_funcs : list Clight.fundef :=
  [ Ctypes.Internal mario.f_debug_print_speed_action_normal
  ; Ctypes.Internal mario.f_mario_floor_is_slippery
  ; Ctypes.Internal mario.f_mario_get_floor_class
  ; Ctypes.Internal mario.f_mario_get_terrain_sound_addend
  ; Ctypes.Internal mario.f_mario_reset_bodystate
  ; Ctypes.Internal mario.f_mario_update_hitbox_and_cap_model
  ; Ctypes.Internal mario.f_set_submerged_cam_preset_and_spawn_bubbles
  ; Ctypes.Internal mario.f_sink_mario_in_quicksand
  ; Ctypes.Internal mario.f_squish_mario_model
  ; Ctypes.Internal mario.f_update_and_return_cap_flags
  ; Ctypes.Internal mario.f_update_mario_button_inputs
  ; Ctypes.Internal mario.f_update_mario_geometry_inputs
  ; Ctypes.Internal mario.f_update_mario_health
  ; Ctypes.Internal mario.f_update_mario_info_for_cam
  ; Ctypes.Internal mario.f_update_mario_inputs
  ; Ctypes.Internal mario.f_update_mario_joystick_inputs
  ; Ctypes.Internal mario.f_vec3f_find_ceil ].

Definition reached_fd (fd : Clight.fundef) : Prop :=
  In fd reached_funcs \/ (exists ef tl ty cc, fd = External ef tl ty cc).

(* ===================================================================== *)
(* THE ACTION-FIELD STORE CENSUS (decidable, machine-checked over the     *)
(* REAL clightgen'd bodies). `no_action_store s` is true iff NO Sassign    *)
(* anywhere in s NAMES *MarioState's* `action` field as its store target,  *)
(* i.e. the body never contains a store of the syntactic shape             *)
(*   Sassign (Efield base _action _) _   with  typeof base = struct        *)
(*   MarioState.                                                           *)
(* The struct-type guard is ESSENTIAL: clightgen interns identifiers by    *)
(* name, so the `_action` ident is SHARED by every struct with an "action" *)
(* field -- MarioState.action (offset 12 of bm, the real action cell) but  *)
(* ALSO MarioBodyState.action and PlayerCameraState.action, which live in  *)
(* DIFFERENT structs / blocks (e.g. update_mario_info_for_cam writes those *)
(* two, not Mario's). Gating on `typeof base = Tstruct _MarioState` makes   *)
(* the census specific to the genuine action cell.                         *)
(* This is the syntactic backbone of the body leaf's C-conjunct: the part  *)
(* of "this function does not write a flying action value" that is         *)
(* decidable purely from the AST, with NO genv / provenance reasoning. The *)
(* residual safety of the non-action stores (Efield to OTHER MarioState    *)
(* fields -- offset <> 12; `*p = v` chase stores; global `Evar g` stores)  *)
(* -- namely that they miss the (bm,12) action CELL -- is a field-offset / *)
(* provenance fact handled by TI in reach_assign_marg, NOT here. clightgen *)
(* emits every `((MarioState* )m)->action = v` write as exactly the shape   *)
(* above, so this census's `= true` certifies the function names Mario's   *)
(* action field as a store target NOWHERE in its body.                     *)
(* ===================================================================== *)
Definition type_is_mariostate (ty : type) : bool :=
  match ty with
  | Tstruct id _ => Pos.eqb id mario._MarioState
  | _            => false
  end.

Definition lval_names_action (a : expr) : bool :=
  match a with
  | Efield base f _ => Pos.eqb f mario._action && type_is_mariostate (typeof base)
  | _               => false
  end.

Fixpoint no_action_store (s : statement) : bool :=
  match s with
  | Sassign lv _        => negb (lval_names_action lv)
  | Ssequence s1 s2     => no_action_store s1 && no_action_store s2
  | Sifthenelse _ s1 s2 => no_action_store s1 && no_action_store s2
  | Sloop s1 s2         => no_action_store s1 && no_action_store s2
  | Slabel _ s1         => no_action_store s1
  | Sswitch _ ls        => no_action_store_ls ls
  | _                   => true
  end
with no_action_store_ls (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => true
  | LScons _ s rest => no_action_store s && no_action_store_ls rest
  end.

(* MACHINE-CHECKED CENSUS: every one of the 17 reached internals' REAL bodies
   names the action field as a store target NOWHERE. Discharged by one
   computation over the clightgen'd ASTs. This is the concrete content of
   "none of the reachable non-set_mario_action internals writes Mario's action
   field" -- the literal claim, certified for the internal reached set. *)
Lemma reached_funcs_no_action_store :
  forallb (fun fd => match fd with
                     | Ctypes.Internal f => no_action_store (fn_body f)
                     | Ctypes.External _ _ _ _ => true
                     end)
          reached_funcs = true.
Proof. vm_compute. reflexivity. Qed.

(* Lifted to the reached-fd gate: a reached INTERNAL function's body passes the
   census. (Externals are governed by the external residual, not this census.) *)
Lemma reached_fd_no_action_store :
  forall f, reached_fd (Ctypes.Internal f) -> no_action_store (fn_body f) = true.
Proof.
  intros f [Hin | (ef & tl & ty & cc & Hext)]; [| discriminate Hext].
  pose proof reached_funcs_no_action_store as H.
  rewrite forallb_forall in H.
  exact (H _ Hin).
Qed.

(* The census distributes over CompCert's switch selection (select_switch /
   seq_of_labeled_statement) -- the bool analogues of RealFrameValue.reach_ssd /
   reach_ssc / reach_seq_of / reach_select_switch. Needed to discharge the
   engine's switch census leaf (reach_C_sw) for the concrete census C below. *)
Lemma no_action_store_ssd : forall sl,
  no_action_store_ls sl = true ->
  no_action_store_ls (select_switch_default sl) = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros H; auto.
  apply andb_true_iff in H. destruct H as [Hs Hr].
  destruct o as [c|]; simpl.
  - apply IH; exact Hr.
  - rewrite Hs, Hr; reflexivity.
Qed.

Lemma no_action_store_ssc : forall n sl res,
  no_action_store_ls sl = true ->
  select_switch_case n sl = Some res -> no_action_store_ls res = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros res Hav Hsel; try discriminate.
  apply andb_true_iff in Hav. destruct Hav as [Hs Hr].
  destruct o as [c|]; simpl in Hsel.
  - destruct (zeq c n).
    + inv Hsel. simpl. rewrite Hs, Hr; reflexivity.
    + exact (IH res Hr Hsel).
  - exact (IH res Hr Hsel).
Qed.

Lemma no_action_store_seq_of : forall ls,
  no_action_store_ls ls = true ->
  no_action_store (seq_of_labeled_statement ls) = true.
Proof.
  induction ls as [| o s rest IH]; simpl; intros H; auto.
  apply andb_true_iff in H. destruct H as [Hs Hr].
  simpl. rewrite Hs, (IH Hr); reflexivity.
Qed.

Lemma no_action_store_select : forall n sl,
  no_action_store_ls sl = true ->
  no_action_store_ls (select_switch n sl) = true.
Proof.
  intros n sl H. unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - exact (no_action_store_ssc n sl l H E).
  - apply no_action_store_ssd; exact H.
Qed.

Section NoAImpliesNoFly.
  (* Mario's struct block is fixed; the action field loads at (bm, 12) as Mint32 --
     exactly the value engine's watched cell. *)
  Variable bm : block.

  (* Mario-memory well-formedness: the abstract invariant the WF value engine
     threads ALONGSIDE action_sat. It is what makes the per-Sset chase load
     `_t = _m->field` land OFF bm -- the fact that re-establishes the entry-temp
     provenance TI after a load, closing the once-unsatisfiable `forall m`
     reach_TI_set. Concretely MWF = "the Mario chase fields point off bm"
     (MarioMemWF block-distinctness); abstract here, discharged downstream. *)
  Variable MWF : mem -> Prop.

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
    Mem.valid_block m bm /\ mem_nonflying m /\ marioObj_wf m bm /\ gMarioState_wf m bm
    /\ MWF m.

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

  (* Reachability gating. `Reached_id`/`reached_fd` carve out the FINITE set of
     functions the frame actually reaches (execute_mario_action + its 17
     writer-free callees; docs/reachable-internal-graph.md). Gating the value
     engine by these is what ESCAPES the `forall f` phantom: the body leaf below
     fires only for ACTUALLY-reached callees, so it is enumerable (case-split the
     17 + vm_compute) rather than a per-function census asserted for every
     conceivable f. Concretely Reached_id := membership in reached_ids and
     Reached_id and reached_fd are now BOTH concrete (reached_id / reached_fd),
     the real reached set. *)

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

     TI/C: the entry-temp invariant and per-body census of the REACHED
     functions. The marg leaf residuals (1a)-(1d) replace the FALSE phantom
     reach_value_body_nonwriter -- each speaks about the actual entry temp env /
     actual call args under a marg_ok guard, never an adversarial `forall le`.

     TI stays ABSTRACT (the provenance residual, reach_value_body_TI below). C is
     now CONCRETE: the decidable MarioState-action store census `no_action_store`,
     machine-checked = true on all 17 reached bodies (reached_fd_no_action_store).
     So the body leaf's C-conjunct -- "this reached non-writer never NAMES Mario's
     action field as a store target" -- is DISCHARGED, not assumed; only the
     TI-conjunct (the temp-provenance invariant) remains a residual. *)
  Variable TI : temp_env -> Prop.
  Let C : statement -> Prop := fun s => no_action_store s = true.
  (* (1a-TI) REACHED + marg-gated body leaf, TI HALF (the residual that remains).
          An ACTUALLY-REACHED non-writer entered with marg_ok args has entry-temp-
          invariant TI. The `reached_fd (Internal f)` premise kills the forall-f
          phantom -- only the finite reached set, dischargeable by enumeration.
          EXECUTION-RELATIVE (the entry le is the one the marg call args produced).
          This is the pointer-PROVENANCE half; the action-write-freedom half (the
          C-conjunct) is now PROVED below from the census, not assumed. *)
  Hypothesis reach_value_body_TI :
    forall f vargs m e le m1,
      reached_fd (Ctypes.Internal f) ->
      function_entry2 mario_ge f vargs m e le m1 ->
      ~ writer_set_mario_action (Ctypes.Internal f) ->
      marg_ok bm vargs ->
      TI le.
  (* (1a) the FULL body leaf the value engine consumes: TI le /\ C (fn_body f).
          The C-conjunct -- "f's body NAMES MarioState's action field as a store
          target NOWHERE" -- is DISCHARGED by the machine-checked census
          reached_fd_no_action_store (vm_compute over all 17 reached bodies); only
          the TI-conjunct is assumed (reach_value_body_TI). So this leaf rests on
          strictly LESS than the old monolithic reach_value_body_marg. *)
  Lemma reach_value_body_marg :
    forall f vargs m e le m1,
      reached_fd (Ctypes.Internal f) ->
      function_entry2 mario_ge f vargs m e le m1 ->
      ~ writer_set_mario_action (Ctypes.Internal f) ->
      marg_ok bm vargs ->
      TI le /\ C (fn_body f).
  Proof.
    intros f vargs m e le m1 Hrf Hentry Hnw Hmarg.
    split.
    - exact (reach_value_body_TI f vargs m e le m1 Hrf Hentry Hnw Hmarg).
    - unfold C. exact (reached_fd_no_action_store f Hrf).
  Qed.
  (* (1a') a direct Sassign under TI+C preserves validity + non-flying (it stores
          off the action cell OR a non-flying value). *)
  Hypothesis reach_assign_marg :
    forall e le m a1 a2 loc ofs bf v2 v m',
      eval_lvalue mario_ge e le m a1 loc ofs bf ->
      eval_expr mario_ge e le m a2 v2 ->
      sem_cast v2 (typeof a2) (typeof a1) m = Some v ->
      assign_loc mario_ge (typeof a1) m loc ofs bf v m' ->
      TI le -> C (Sassign a1 a2) -> MWF m ->
      Mem.valid_block m bm -> action_sat nonflying m bm ->
      Mem.valid_block m' bm /\ action_sat nonflying m' bm /\ MWF m'.
  (* (1a'') under TI, a reached call's evaluated args are marg_ok (the Mario arg
           temp is (bm,0)-or-off-bm) -- the call-site bridge that THREADS marg. *)
  Hypothesis reach_call_marg :
    forall e le m optid a al tyargs vargs,
      TI le -> C (Scall optid a al) ->
      eval_exprlist mario_ge e le m al tyargs vargs -> marg_ok bm vargs.
  (* (1a''') TI is preserved by a censused Sset and by a censused call/builtin result. *)
  Hypothesis reach_TI_set :
    forall e le m id a v,
      MWF m -> eval_expr mario_ge e le m a v -> TI le -> C (Sset id a) ->
      TI (PTree.set id v le).
  Hypothesis reach_TI_optc :
    forall optid a al v le, C (Scall optid a al) -> TI le -> TI (set_opttemp optid v le).
  Hypothesis reach_TI_optb :
    forall optid ef tyargs al v le,
      C (Sbuiltin optid ef tyargs al) -> TI le -> TI (set_opttemp optid v le).
  (* (1a'''') the census C distributes over the compound statement forms -- now
          PROVED from the `no_action_store` Fixpoint (&& / switch-selection), not
          assumed. *)
  Lemma reach_C_seq  : forall s1 s2, C (Ssequence s1 s2) -> C s1 /\ C s2.
  Proof. unfold C; intros s1 s2 H; simpl in H; apply andb_true_iff in H; exact H. Qed.
  Lemma reach_C_if   : forall a s1 s2, C (Sifthenelse a s1 s2) -> C s1 /\ C s2.
  Proof. unfold C; intros a s1 s2 H; simpl in H; apply andb_true_iff in H; exact H. Qed.
  Lemma reach_C_loop : forall s1 s2, C (Sloop s1 s2) -> C s1 /\ C s2.
  Proof. unfold C; intros s1 s2 H; simpl in H; apply andb_true_iff in H; exact H. Qed.
  Lemma reach_C_sw   :
    forall a ls n, C (Sswitch a ls) -> C (seq_of_labeled_statement (select_switch n ls)).
  Proof.
    unfold C; intros a ls n H; simpl in H.
    apply no_action_store_seq_of, no_action_store_select; exact H.
  Qed.
  (* (1a''''') THE CALL-TARGET-REACHED BRIDGE (value engine). Under TI+C, a reached
          call resolves to a Reached callee -- the semantic image of the decidable
          callgraph closure (CallgraphReach.reaches; the static-graph half is
          machine-checked in Unwired/ReachScratch over the real mario.prog). This
          is what threads reachability through the reached callees' OWN calls; its
          discharge is the isolated genv resolution (Evar id -> find_symbol id ->
          fd at id), NOT a forall over functions. *)
  Hypothesis reach_call_reached :
    forall e le m optid a al vf fd,
      TI le -> C (Scall optid a al) ->
      eval_expr mario_ge e le m a vf -> Genv.find_funct mario_ge vf = Some fd ->
      reached_fd fd.
  (* (1b) THE WRITER CASE, now REACHED-gated -- DISCHARGED BY VACUITY (no longer a
          residual). set_mario_action is the sole internal action writer, and it is
          NOT among the 17 reached funcs (reached_funcs), so `reached_fd
          (Internal f_set_mario_action)` is FALSE: this leaf never fires. The
          forall-vargs phantom of the old writer leaf is gone; the cross-TU A-gated
          dispatch is governed by the EXTERNAL residual (3). *)
  Lemma reach_writer_ok :
    forall m fd vargs t m' vres,
      reached_fd fd -> NoA m -> MWF m ->
      eval_funcall function_entry2 mario_ge m fd vargs t m' vres ->
      writer_set_mario_action fd ->
      Mem.valid_block m bm -> action_sat nonflying m bm ->
      Mem.valid_block m' bm /\ action_sat nonflying m' bm /\ MWF m'.
  Proof.
    intros m fd vargs t m' vres Hrf _ _ _ Hwr _ _.
    unfold writer_set_mario_action in Hwr. subst fd.
    exfalso. destruct Hrf as [Hin | (ef & tl & ty & cc & Hext)].
    - revert Hin. unfold reached_funcs. intro H.
      repeat (destruct H as [H | H]);
        [ apply (f_equal (fun fd => match fd with
                                    | Ctypes.Internal f => fn_body f
                                    | _ => Sskip end)) in H;
          vm_compute in H; discriminate H ..
        | contradiction ].
    - discriminate Hext.
  Qed.
  (* (1c) reached externals don't write the action cell. NB: these "externals"
          INCLUDE the cross-TU action handlers (the mario_execute_ / act_ family) --
          so this is a STRONG assumption that currently holds the real crux, to be
          discharged by linking, not a mere math/memcpy boundary. *)
  Hypothesis reach_ext_action_cell :
    reach_ext_preserves (action_cell bm) mario_ge.
  (* (1d) the WF invariant survives the operations the value engine threads it
          through, beyond the action cell. A reached external preserves MWF
          (externals are memcpy/bzero-class -- they don't scramble the chase
          fields' provenance), and MWF survives anything that leaves bm's cells
          unchanged (function entry's fresh-block allocation + frame free). Both
          are exactly the bm-local facts the WF engine demands at its entry/free
          and Sbuiltin leaves; concrete content = the chase fields stay off bm. *)
  Hypothesis Hmwf_ext :
    forall ef vargs m t vres m',
      external_call ef mario_ge vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.
  Hypothesis Hmwf_unch :
    forall m m', Mem.unchanged_on (fun b _ => b = bm) m m' ->
                 Mem.valid_block m bm -> MWF m -> MWF m'.
  (* (2) every reached funcall ALSO preserves NoA and the two Mario-pointer
     invariants (marioObj off bm, gMarioState -> bm); together with (1) this is
     the engine's full no-A-conditioned reach. A call-graph fact about the
     REACHED functions, the next discharge target (per-function offset analysis).*)
  Hypothesis reach_rest_ok : reach_rest_marg bm NoA.
  (* (3) every reached external, in a no-A state, preserves NoA and the full
     memory invariant (SM64 externals are memcpy/bzero-class). *)
  Hypothesis ext_meminv_ok :
    forall ef vargs mm tt vres mm',
      NoA mm -> meminv bm mm -> MWF mm ->
      external_call ef mario_ge vargs mm tt vres mm' ->
      NoA mm' /\ meminv bm mm' /\ MWF mm'.
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
  (* (4b) execute_mario_action's OWN body stores (the 2 census'd Sassigns through
     `_bodyState->field`) preserve MWF -- they hit the chase fields, not the
     provenance-defining cells of bm. The body-engine counterpart of the noA
     store-propagation closure; concrete content = MarioMemWF block-distinctness. *)
  Hypothesis store_mwf :
    forall e le mm a1 a2 tt le' mm' out,
      NoA mm -> prov_ok (Sassign a1 a2) -> MWF mm ->
      exec_stmt function_entry2 mario_ge e le mm (Sassign a1 a2) tt le' mm' out -> MWF mm'.
  (* (4c) THE BODY'S CALL TARGETS ARE REACHED. The call-target-reached bridge for
     execute_mario_action's OWN body: each censused call (reach_chk) resolves to a
     Reached callee. Together with body_reach_chk this threads reached_fd from the
     frame root to the value engine -- the body-engine analogue of
     reach_call_reached. Discharge: per-call genv resolution over the finite body. *)
  Hypothesis body_calls_reached :
    forall oid a al e le mm vf fd,
      reach_chk reached_id (Scall oid a al) ->
      eval_expr mario_ge e le mm a vf ->
      Genv.find_funct mario_ge vf = Some fd -> reached_fd fd.
  (* (4d) execute_mario_action's body passes the syntactic call-target census:
     every direct call in it targets `Evar id` with `reached_id id`. NO LONGER a
     residual -- DISCHARGED here by computation over the REAL clightgen'd body
     (the closure base Unwired/ReachScratch.emA_callees_are_reached_or_external
     is the machine-checked decidable core). *)
  Lemma body_reach_chk :
    reach_chk reached_id (fn_body mario.f_execute_mario_action).
  Proof.
    cbn [reach_chk reach_chk_ls fn_body mario.f_execute_mario_action Swhile];
      unfold reached_id; repeat split; reflexivity.
  Qed.
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
    intros i m m' Ha _ (Hv & Hsat & Hwf & Hgwf & HMWF) Hst.
    assert (HnoA : NoA m) by (eapply input_grounds_noA; eassumption).
    (* the SOUND MARG+WF value engine: marg-gated leaf-A (non-writer direct bodies
       under TI+C) + the no-A writer case + ext + NoA-propagation -> the action
       stays non-flying across every reached funcall WHOSE Mario arg is marg_ok.
       The WF invariant MWF is threaded ALONGSIDE action_sat so the per-Sset chase
       load `_t = _m->field` re-establishes the entry-temp provenance TI (closing
       the once-unsatisfiable forall-m reach_TI_set). The body engine supplies
       marg_ok at the real call sites. *)
    pose proof (exec_funcall_reach_value_reached nonflying bm mario_ge NoA MWF
                  writer_set_mario_action reached_fd TI C
                  reach_value_body_marg reach_assign_marg reach_call_marg
                  reach_TI_set reach_TI_optc reach_TI_optb
                  reach_call_reached reach_writer_ok reach_ext_action_cell
                  Hmwf_ext Hmwf_unch noA_exec_ok noA_entry_ok
                  reach_C_seq reach_C_if reach_C_loop reach_C_sw)
      as Hreach.
    destruct (execute_mario_action_preserves_real_reached bm NoA MWF
                reached_id reached_fd m m'
                Hreach reach_rest_ok ext_meminv_ok
                (fun e le mm a1 a2 tt le' mm' out HnoA' _ Hexec =>
                   noA_exec_ok e le mm (Sassign a1 a2) tt le' mm' out Hexec HnoA')
                store_mwf body_calls_reached body_reach_chk
                HnoA HMWF Hv Hsat Hwf Hgwf Hst)
      as (_ & Hv' & Hs' & Hw' & Hgw' & HMWF').
    exact (conj Hv' (conj Hs' (conj Hw' (conj Hgw' HMWF')))).
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
