(** Rank 11's finite, generated-source pole exit split.

    This is a complete census of the direct action requests in the six pole
    handlers and their positioning helper, not a claim that all their callees
    preserve Mario.  The only removed branches are the exact adjacent
    [m->input] load / [INPUT_A_PRESSED] tests.  The companion execution file
    executes those tests from memory and the non-jumping airborne initializer.
    Runtime input provenance, collision results, aliases and outside effects
    are deliberately not inferred from this syntax census. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Clightdefs Cop Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_mario jp_mario us_mario_actions_automatic jp_mario_actions_automatic.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Module R11U := us_mario_actions_automatic.
Module R11J := jp_mario_actions_automatic.
Module R11MU := us_mario.
Module R11MJ := jp_mario.

Inductive Rank11PoleHandler :=
| R11Holding | R11Climbing | R11GrabSlow | R11GrabFast
| R11TopTransition | R11Top | R11Position.

Definition rank11_pole_handlers : list Rank11PoleHandler :=
  [R11Holding; R11Climbing; R11GrabSlow; R11GrabFast;
   R11TopTransition; R11Top; R11Position].

Definition rank11_pole_body (version : GameVersion) (handler : Rank11PoleHandler)
    : function :=
  match version, handler with
  | VersionUS, R11Holding => R11U.f_act_holding_pole
  | VersionUS, R11Climbing => R11U.f_act_climbing_pole
  | VersionUS, R11GrabSlow => R11U.f_act_grab_pole_slow
  | VersionUS, R11GrabFast => R11U.f_act_grab_pole_fast
  | VersionUS, R11TopTransition => R11U.f_act_top_of_pole_transition
  | VersionUS, R11Top => R11U.f_act_top_of_pole
  | VersionUS, R11Position => R11U.f_set_pole_position
  | VersionJP, R11Holding => R11J.f_act_holding_pole
  | VersionJP, R11Climbing => R11J.f_act_climbing_pole
  | VersionJP, R11GrabSlow => R11J.f_act_grab_pole_slow
  | VersionJP, R11GrabFast => R11J.f_act_grab_pole_fast
  | VersionJP, R11TopTransition => R11J.f_act_top_of_pole_transition
  | VersionJP, R11Top => R11J.f_act_top_of_pole
  | VersionJP, R11Position => R11J.f_set_pole_position
  end.

Definition rank11_pole_ident (handler : Rank11PoleHandler) : ident :=
  match handler with
  | R11Holding => R11U._act_holding_pole
  | R11Climbing => R11U._act_climbing_pole
  | R11GrabSlow => R11U._act_grab_pole_slow
  | R11GrabFast => R11U._act_grab_pole_fast
  | R11TopTransition => R11U._act_top_of_pole_transition
  | R11Top => R11U._act_top_of_pole
  | R11Position => R11U._set_pole_position
  end.

Definition rank11_mario_pointer_type : type :=
  tptr (Tstruct R11U._MarioState noattr).

Definition rank11_input_expression : expr :=
  Efield (Ederef (Etempvar R11U._m rank11_mario_pointer_type)
    (Tstruct R11U._MarioState noattr)) R11U._input tushort.

(** Recognize the WHOLE load/test pair, including the base temporary and
    types.  It is not enough to find the constant 2 somewhere in a body. *)
Definition rank11_a_test (first second : statement) : bool :=
  match first, second with
  | Sset loaded
      (Efield (Ederef (Etempvar mario (Tpointer (Tstruct tag1 _) _))
        (Tstruct tag2 _)) field (Tint I16 Unsigned _)),
    Sifthenelse (Ebinop Oand (Etempvar tested (Tint I16 Unsigned _))
      (Econst_int mask (Tint I32 Signed _)) (Tint I32 Signed _)) _ Sskip =>
      Pos.eqb mario R11U._m && Pos.eqb tag1 R11U._MarioState &&
      Pos.eqb tag2 R11U._MarioState && Pos.eqb field R11U._input &&
      Pos.eqb loaded tested && Int.eq mask (Int.repr 2)
  | _, _ => false
  end.

Definition rank11_a_guard_block (temporary : ident) (yes : statement) :=
  Ssequence (Sset temporary rank11_input_expression)
    (Sifthenelse (Ebinop Oand (Etempvar temporary tushort)
      (Econst_int (Int.repr 2) tint) tint) yes Sskip).

Fixpoint rank11_a_guard_blocks (body : statement) : list statement :=
  match body with
  | Ssequence first second =>
      if rank11_a_test first second then [body]
      else rank11_a_guard_blocks first ++ rank11_a_guard_blocks second
  | Sifthenelse _ yes no => rank11_a_guard_blocks yes ++ rank11_a_guard_blocks no
  | _ => []
  end.

Theorem rank11_all_removed_guards_have_the_executed_shape :
  forall version handler block,
    In block (rank11_a_guard_blocks (fn_body (rank11_pole_body version handler))) ->
    exists temporary yes, block = rank11_a_guard_block temporary yes.
Proof.
  intros [] [] block; cbn [rank11_pole_body rank11_a_guard_blocks rank11_a_test];
    intros H; repeat destruct H as [H | H]; try contradiction;
    subst block; do 2 eexists; reflexivity.
Qed.

(** Return every action/argument pair, failing closed on indirect calls,
    builtins, nonliteral action requests, loops, switches and gotos.  None of
    those constructs occurs in the seven audited bodies. *)
Definition rank11_join_actions (left right : option (list (Z * Z))) :=
  match left, right with
  | Some l, Some r => Some (l ++ r)
  | _, _ => None
  end.

Fixpoint rank11_action_requests (without_a : bool) (body : statement)
    : option (list (Z * Z)) :=
  match body with
  | Scall _ (Evar callee _) arguments =>
      if Pos.eqb callee R11U._set_mario_action then
        match arguments with
        | [Etempvar mario _; Econst_int action _; Econst_int arg _] =>
            if Pos.eqb mario R11U._m
            then Some [(Int.unsigned action, Int.unsigned arg)] else None
        | _ => None
        end
      else Some []
  | Ssequence first second =>
      if without_a && rank11_a_test first second then Some []
      else rank11_join_actions (rank11_action_requests without_a first)
             (rank11_action_requests without_a second)
  | Sifthenelse _ yes no =>
      rank11_join_actions (rank11_action_requests without_a yes)
        (rank11_action_requests without_a no)
  | Sskip | Sassign _ _ | Sset _ _ | Sreturn _ => Some []
  | _ => None
  end.

Definition rank11_expected_no_a_actions
    (version : GameVersion) (handler : Rank11PoleHandler) : list (Z * Z) :=
  match handler with
  | R11Holding => [(16910518, 0); (1049411, 0); (1049412, 0)]
  | R11Climbing =>
      match version with
      | VersionUS => [(16910518, 0); (135267136, 0)]
      | VersionJP => [(135267136, 0)]
      end
  | R11GrabSlow | R11GrabFast => [(135267136, 0)]
  | R11TopTransition => [(1049413, 0); (135267136, 0)]
  | R11Top => [(1049412, 1)]
  | R11Position =>
      [(205521409, 0); (16779404, 0); (16910518, 0); (205521409, 0)]
  end.

Theorem rank11_all_no_a_direct_action_requests_are_enumerated :
  forall version handler,
    rank11_action_requests true (fn_body (rank11_pole_body version handler)) =
      Some (rank11_expected_no_a_actions version handler).
Proof. intros [] []; vm_compute; reflexivity. Qed.

Definition rank11_expected_all_actions
    (version : GameVersion) (handler : Rank11PoleHandler) : list (Z * Z) :=
  match handler with
  | R11Holding =>
      match version with
      | VersionUS => [(16910518, 0); (50333830, 0); (1049411, 0); (1049412, 0)]
      | VersionJP => [(50333830, 0); (16910518, 0); (1049411, 0); (1049412, 0)]
      end
  | R11Climbing =>
      match version with
      | VersionUS => [(16910518, 0); (50333830, 0); (135267136, 0)]
      | VersionJP => [(50333830, 0); (135267136, 0)]
      end
  | R11Top => [(50333837, 0); (1049412, 1)]
  | _ => rank11_expected_no_a_actions version handler
  end.

(** Authenticate what was removed, not merely the number of removed calls:
    the two wall-kick requests and the top-of-pole jump are the A branches. *)
Theorem rank11_all_direct_action_requests_are_enumerated :
  forall version handler,
    rank11_action_requests false (fn_body (rank11_pole_body version handler)) =
      Some (rank11_expected_all_actions version handler).
Proof. intros [] []; vm_compute; reflexivity. Qed.

Definition rank11_a_guard_count (version : GameVersion) : list nat :=
  map (fun handler =>
    let body := fn_body (rank11_pole_body version handler) in
    match rank11_action_requests false body,
          rank11_action_requests true body with
    | Some before, Some after => (length before - length after)%nat
    | _, _ => 99%nat
    end) rank11_pole_handlers.

Theorem rank11_exactly_three_upward_pole_requests_are_a_guarded :
  rank11_a_guard_count VersionUS = [1; 1; 0; 0; 0; 1; 0]%nat /\
  rank11_a_guard_count VersionJP = [1; 1; 0; 0; 0; 1; 0]%nat /\
  forall version handler action arg,
    In (action, arg) (rank11_expected_no_a_actions version handler) ->
    In action [16910518; 16779404; 205521409; 135267136; 1049411; 1049412; 1049413].
Proof.
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  intros [] [] action arg; cbn; intuition congruence.
Qed.

(** The automatic common cancel must not be silently folded into the three
    pole-release actions.  It has one water-plunge call and no direct setter. *)
Theorem rank11_water_cancel_is_separate :
  rank11_action_requests false
    (fn_body R11U.f_check_common_automatic_cancels) = Some [] /\
  rank11_action_requests false
    (fn_body R11J.f_check_common_automatic_cancels) = Some [] /\
  calls_ident_s R11U._set_water_plunge_action
    (fn_body R11U.f_check_common_automatic_cancels) = true /\
  calls_ident_s R11J._set_water_plunge_action
    (fn_body R11J.f_check_common_automatic_cancels) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition rank11_airborne_body (version : GameVersion) : function :=
  match version with
  | VersionUS => R11MU.f_set_mario_action_airborne
  | VersionJP => R11MJ.f_set_mario_action_airborne
  end.

Definition rank11_airborne_prefix (version : GameVersion) : statement :=
  match fn_body (rank11_airborne_body version) with
  | Ssequence prefix _ => prefix
  | _ => Sskip
  end.

Definition rank11_airborne_switch_cases (version : GameVersion)
    : labeled_statements :=
  match fn_body (rank11_airborne_body version) with
  | Ssequence _ (Ssequence (Sswitch _ cases) _) => cases
  | _ => LSnil
  end.

Definition rank11_airborne_tail (version : GameVersion) : statement :=
  match fn_body (rank11_airborne_body version) with
  | Ssequence _ (Ssequence _ tail) => tail
  | _ => Sskip
  end.

Inductive Rank11FallingExit := R11SoftBonk | R11Freefall.

Definition rank11_falling_action (exit : Rank11FallingExit) : int :=
  Int.repr (match exit with R11SoftBonk => 16910518 | R11Freefall => 16779404 end).

Theorem rank11_falling_exits_select_no_jump_initializer :
  forall version exit,
    select_switch (Int.unsigned (rank11_falling_action exit))
      (rank11_airborne_switch_cases version) = LSnil.
Proof. intros [] []; vm_compute; reflexivity. Qed.

Theorem rank11_airborne_body_decomposition : forall version,
  fn_body (rank11_airborne_body version) =
    Ssequence (rank11_airborne_prefix version)
      (Ssequence
        (Sswitch (Etempvar R11MU._action tuint)
          (rank11_airborne_switch_cases version))
        (rank11_airborne_tail version)).
Proof. intros []; reflexivity. Qed.

Definition Rank11PoleExitSourceBoundary : Prop :=
  (forall version handler,
    rank11_action_requests false (fn_body (rank11_pole_body version handler)) =
      Some (rank11_expected_all_actions version handler)) /\
  (forall version handler,
    rank11_action_requests true (fn_body (rank11_pole_body version handler)) =
      Some (rank11_expected_no_a_actions version handler)) /\
  (forall version exit,
    select_switch (Int.unsigned (rank11_falling_action exit))
      (rank11_airborne_switch_cases version) = LSnil).

Theorem rank11_pole_exit_source_boundary_holds : Rank11PoleExitSourceBoundary.
Proof.
  split; [exact rank11_all_direct_action_requests_are_enumerated |].
  split; [exact rank11_all_no_a_direct_action_requests_are_enumerated |
    exact rank11_falling_exits_select_no_jump_initializer].
Qed.
