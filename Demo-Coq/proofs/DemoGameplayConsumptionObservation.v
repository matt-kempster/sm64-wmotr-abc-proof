From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs Coqlib Cop Ctypes Errors
  Events Globalenvs Integers Maps Memory Smallstep Values.
From Demo.Generated Require Import us_camera jp_camera us_level_update
  jp_level_update us_level_script jp_level_script.
From Demo.Proofs Require Import DemoExecutionHistory.
Import ListNotations.
Local Open Scope Z_scope.
Module C := us_camera.

(** This is an application observation, not a no-desync invariant.  In
    particular it has no level, scene coherence, stream ownership, fade or
    play-mode premise.  Those belong to the full execution specification. *)

Definition demo_normal_update (us : bool) : function :=
  if us then us_level_update.f_play_mode_normal else jp_level_update.f_play_mode_normal.
Definition demo_basic_update (us : bool) : function :=
  if us then us_level_update.f_basic_update else jp_level_update.f_basic_update.
Definition demo_script_object_update (us : bool) : function :=
  if us then us_level_script.f_level_cmd_2D else jp_level_script.f_level_cmd_2D.

Definition demo_gameplay_update_root (us : bool) (f : function) : Prop :=
  f = demo_normal_update us \/ f = demo_basic_update us \/
  f = demo_script_object_update us.

(** Only the two real object/camera update calls qualify.  A read in the
    normal-update Start/END bookkeeping prefix does not qualify merely because
    its caller is play_mode_normal. *)
Inductive demo_gameplay_update_call : statement -> Prop :=
| demo_objects_update_call :
    demo_gameplay_update_call
      (Scall None (Evar us_level_update._area_update_objects (Tfunction nil tvoid cc_default)) nil)
| demo_camera_update_call : forall args,
    demo_gameplay_update_call
      (Scall None (Evar C._update_camera
        (Tfunction ((tptr (Tstruct C._Camera noattr)) :: nil) tvoid cc_default)) args).

(** A structural certificate of the residual continuation for an update call
    actually occurring in a generated root body.  The three current roots
    require only sequence/conditional contexts; no invented frame transition
    relation is introduced.  Full histories still establish reachability. *)
Inductive demo_update_call_context : statement -> cont -> cont -> Prop :=
| demo_update_context_here : forall call k,
    demo_gameplay_update_call call -> demo_update_call_context call k k
| demo_update_context_sequence_left : forall a b k residual,
    demo_update_call_context a (Kseq b k) residual ->
    demo_update_call_context (Ssequence a b) k residual
| demo_update_context_sequence_right : forall a b k residual,
    demo_update_call_context b k residual ->
    demo_update_call_context (Ssequence a b) k residual
| demo_update_context_if_true : forall test yes no k residual,
    demo_update_call_context yes k residual ->
    demo_update_call_context (Sifthenelse test yes no) k residual
| demo_update_context_if_false : forall test yes no k residual,
    demo_update_call_context no k residual ->
    demo_update_call_context (Sifthenelse test yes no) k residual.

(** The original Clight continuation retains the selected generated update's
    Kcall frame through deeper object/behavior/camera calls and local control.
    Thus basic_update callbacks and script opcode2D are included, without a
    test excluding a real application during a title fade or transition. *)
Inductive demo_gameplay_dynamic_context (us : bool) : cont -> Prop :=
| demo_dynamic_update_anchor : forall caller e le base residual,
    demo_gameplay_update_root us caller ->
    demo_update_call_context (fn_body caller) base residual ->
    demo_gameplay_dynamic_context us (Kcall None caller e le residual)
| demo_dynamic_sequence : forall s k,
    demo_gameplay_dynamic_context us k -> demo_gameplay_dynamic_context us (Kseq s k)
| demo_dynamic_loop_first : forall a b k,
    demo_gameplay_dynamic_context us k -> demo_gameplay_dynamic_context us (Kloop1 a b k)
| demo_dynamic_loop_second : forall a b k,
    demo_gameplay_dynamic_context us k -> demo_gameplay_dynamic_context us (Kloop2 a b k)
| demo_dynamic_switch : forall k,
    demo_gameplay_dynamic_context us k -> demo_gameplay_dynamic_context us (Kswitch k)
| demo_dynamic_descendant_call : forall id f e le k,
    demo_gameplay_dynamic_context us k -> demo_gameplay_dynamic_context us (Kcall id f e le k).

Definition demo_controller_read_field (field : ident) (ty : type) : Prop :=
  (field = C._rawStickX /\ ty = tshort) \/
  (field = C._rawStickY /\ ty = tshort) \/
  (field = C._stickX /\ ty = tfloat) \/
  (field = C._stickY /\ ty = tfloat) \/
  (field = C._stickMag /\ ty = tfloat) \/
  (field = C._buttonDown /\ ty = tushort) \/
  (field = C._buttonPressed /\ ty = tushort).

(** The target Controller address is evaluated, not assumed to alias P1.
    Authentic input-origin receipts must establish which controller and record
    supplied these bytes; failing that classification must not hide a read.
    The whole field expression is evaluated by the real Clight load rule. *)
Definition demo_gameplay_read_state (us : bool) (ge : Clight.genv)
    (s : Clight.state) (controller : block) (offset : ptrofs)
    (field : ident) (value : val) : Prop :=
  exists f dst ptr ty k e le m,
    s = State f
      (Sset dst (Efield (Ederef ptr (Tstruct C._Controller noattr)) field ty)) k e le m /\
    demo_controller_read_field field ty /\
    demo_gameplay_dynamic_context us k /\
    eval_expr ge e le m ptr (Vptr controller offset) /\
    eval_expr ge e le m
      (Efield (Ederef ptr (Tstruct C._Controller noattr)) field ty) value.

Definition demo_gameplay_consumption_step (us : bool) (ge : Clight.genv)
    (before after : Clight.state) (controller : block) (offset : ptrofs)
    (field : ident) (value : val) : Prop :=
  demo_gameplay_read_state us ge before controller offset field value /\
  Clight.step2 ge before E0 after.

Definition demo_gameplay_consumption_observation (us : bool) (prog : Clight.program)
    (h : demo_execution_history prog) (i : nat)
    (controller : block) (offset : ptrofs) (field : ident) (value : val) : Prop :=
  (i < history_length h)%nat /\
  demo_gameplay_consumption_step us (Clight.globalenv prog)
    (history_state h i) (history_state h (S i)) controller offset field value /\
  history_trace h i = E0.

Lemma demo_gameplay_read_constructs_actual_step : forall us ge state controller offset field value,
  demo_gameplay_read_state us ge state controller offset field value ->
  exists after, demo_gameplay_consumption_step us ge state after controller offset field value.
Proof.
  intros us ge state controller offset field value Hread.
  destruct Hread as (f & dst & ptr & ty & k & e & le & m & Heq & Hfield & Hcontext & Hptr & Hvalue).
  subst state. eexists. split.
  - do 8 eexists; repeat split; eassumption || reflexivity.
  - unfold Clight.step2. apply step_set. exact Hvalue.
Qed.

Lemma demo_gameplay_consumption_history_step : forall us prog h i controller offset field value,
  demo_gameplay_consumption_observation us prog h i controller offset field value ->
  Clight.step2 (Clight.globalenv prog) (history_state h i) E0
    (history_state h (S i)).
Proof. intros us prog h i controller offset field value (_ & (_ & Hstep) & _). exact Hstep. Qed.

Theorem demo_history_read_is_consumption : forall us prog h i controller offset field value,
  (i < history_length h)%nat ->
  demo_gameplay_read_state us (Clight.globalenv prog) (history_state h i)
    controller offset field value ->
  demo_gameplay_consumption_observation us prog h i controller offset field value.
Proof.
  intros us prog h i controller offset field value Hbound Hread.
  pose proof (history_step h i Hbound) as Hstep.
  assert (Htrace : history_trace h i = E0).
  { destruct Hread as (f & dst & ptr & ty & k & e & le & m & Heq & Hrest).
    unfold Clight.step2 in Hstep. rewrite Heq in Hstep. inversion Hstep; reflexivity. }
  split; [exact Hbound |]. split; [split; [exact Hread |] | exact Htrace].
  rewrite <- Htrace. exact Hstep.
Qed.

Fixpoint demo_sequence_tail (n : nat) (s : statement) : statement :=
  match n, s with
  | O, _ => s
  | S n', Ssequence _ tail => demo_sequence_tail n' tail
  | _, _ => Sskip
  end.

Definition demo_normal_objects_return (us : bool) : statement :=
  match demo_sequence_tail 4 (fn_body (demo_normal_update us)) with
  | Ssequence _ tail => tail | _ => Sskip end.

Lemma generated_normal_objects_update_context : forall us k,
  demo_update_call_context (fn_body (demo_normal_update us)) k
    (Kseq (demo_normal_objects_return us) k).
Proof.
  intros [] k; cbn [demo_normal_update demo_normal_objects_return demo_sequence_tail
    us_level_update.f_play_mode_normal jp_level_update.f_play_mode_normal fn_body];
    do 4 apply demo_update_context_sequence_right;
    apply demo_update_context_sequence_left; apply demo_update_context_here;
    apply demo_objects_update_call.
Qed.

Lemma generated_basic_camera_update_context : forall us k,
  demo_update_call_context (fn_body (demo_basic_update us)) k k.
Proof.
  intros [] k; cbn [demo_basic_update us_level_update.f_basic_update jp_level_update.f_basic_update fn_body];
    do 3 apply demo_update_context_sequence_right;
    apply demo_update_context_if_true;
    do 2 apply demo_update_context_sequence_right;
    apply demo_update_context_here; apply demo_camera_update_call.
Qed.

Definition demo_normal_camera_return (us : bool) : statement :=
  match demo_sequence_tail 6 (fn_body (demo_normal_update us)) with
  | Ssequence _ tail => tail | _ => Sskip end.

Lemma generated_normal_camera_update_context : forall us k,
  demo_update_call_context (fn_body (demo_normal_update us)) k
    (Kseq (demo_normal_camera_return us) k).
Proof.
  intros [] k; cbn [demo_normal_update demo_normal_camera_return demo_sequence_tail
    us_level_update.f_play_mode_normal jp_level_update.f_play_mode_normal fn_body];
    do 6 apply demo_update_context_sequence_right;
    apply demo_update_context_sequence_left;
    apply demo_update_context_sequence_right; apply demo_update_context_if_true;
    do 2 apply demo_update_context_sequence_right;
    apply demo_update_context_here; apply demo_camera_update_call.
Qed.

Definition demo_basic_objects_return (us : bool) : statement :=
  match fn_body (demo_basic_update us) with
  | Ssequence _ tail => tail | _ => Sskip end.

Lemma generated_basic_objects_update_context : forall us k,
  demo_update_call_context (fn_body (demo_basic_update us)) k
    (Kseq (demo_basic_objects_return us) k).
Proof.
  intros [] k; cbn [demo_basic_update demo_basic_objects_return
    us_level_update.f_basic_update jp_level_update.f_basic_update fn_body];
    apply demo_update_context_sequence_left; apply demo_update_context_here;
    apply demo_objects_update_call.
Qed.

Definition demo_script_objects_return (us : bool) : statement :=
  match fn_body (demo_script_object_update us) with
  | Ssequence _ tail => tail | _ => Sskip end.

Lemma generated_script_objects_update_context : forall us k,
  demo_update_call_context (fn_body (demo_script_object_update us)) k
    (Kseq (demo_script_objects_return us) k).
Proof.
  intros [] k; cbn [demo_script_object_update demo_script_objects_return
    us_level_script.f_level_cmd_2D jp_level_script.f_level_cmd_2D fn_body];
    apply demo_update_context_sequence_left; apply demo_update_context_here;
    apply demo_objects_update_call.
Qed.

(** Select the actual first Controller.buttonPressed load in update_camera.
    A successful selector equality below is a source certificate, not a
    handwritten replacement function or a caller-execution oracle. *)
Definition demo_first_some (a b : option statement) : option statement :=
  match a with Some _ => a | None => b end.

Fixpoint demo_find_pressed_load (s : statement) : option statement :=
  match s with
  | Sset dst (Efield (Ederef ptr (Tstruct tag attrs)) field ty) =>
      if Pos.eqb tag C._Controller && Pos.eqb field C._buttonPressed
      then Some s else None
  | Ssequence a b => demo_first_some (demo_find_pressed_load a) (demo_find_pressed_load b)
  | Sifthenelse _ a b => demo_first_some (demo_find_pressed_load a) (demo_find_pressed_load b)
  | _ => None
  end.

Definition demo_camera_pressed_read : statement :=
  Sset C._t'66
    (Efield (Ederef (Etempvar C._t'65 (tptr (Tstruct C._Controller noattr)))
      (Tstruct C._Controller noattr)) C._buttonPressed tushort).

Lemma generated_camera_pressed_read_hook_us_jp :
  demo_find_pressed_load (fn_body us_camera.f_update_camera) = Some demo_camera_pressed_read /\
  demo_find_pressed_load (fn_body jp_camera.f_update_camera) = Some demo_camera_pressed_read.
Proof. split; reflexivity. Qed.

Definition demo_camera_program (us : bool) : Clight.program :=
  if us then us_camera.prog else jp_camera.prog.
Definition demo_camera_update (us : bool) : function :=
  if us then us_camera.f_update_camera else jp_camera.f_update_camera.

Definition demo_camera_controller_members : members :=
  [Member_plain C._rawStickX tshort; Member_plain C._rawStickY tshort;
   Member_plain C._stickX tfloat; Member_plain C._stickY tfloat;
   Member_plain C._stickMag tfloat; Member_plain C._buttonDown tushort;
   Member_plain C._buttonPressed tushort;
   Member_plain C._statusData (tptr (Tstruct C.__317 noattr));
   Member_plain C._controllerData (tptr (Tstruct C.__319 noattr))].

Lemma demo_observation_mkprogram_types : forall types defs public main
    (WF : wf_composites types),
  prog_types (mkprogram types defs public main WF) = types.
Proof. intros. unfold mkprogram. destruct (build_composite_env' types WF). reflexivity. Qed.

Lemma generated_camera_observation_type_list : forall us,
  prog_types (demo_camera_program us) = if us then C.composites else jp_camera.composites.
Proof.
  intros []; cbn [demo_camera_program].
  - unfold C.prog. apply demo_observation_mkprogram_types.
  - unfold jp_camera.prog. apply demo_observation_mkprogram_types.
Qed.

Lemma generated_camera_controller_definition : forall us,
  In (Composite C._Controller Struct demo_camera_controller_members noattr)
    (prog_types (demo_camera_program us)).
Proof.
  intros us; rewrite generated_camera_observation_type_list.
  destruct us; vm_compute; repeat first [left; reflexivity | right].
Qed.

Lemma generated_camera_pressed_layout : forall us ge,
  genv_cenv ge = prog_comp_env (demo_camera_program us) ->
  exists co, (genv_cenv ge) ! C._Controller = Some co /\
    field_offset (genv_cenv ge) C._buttonPressed (co_members co) = OK (18, Full).
Proof.
  intros us ge Henv.
  destruct (build_composite_env_charact C._Controller Struct demo_camera_controller_members noattr
    (prog_types (demo_camera_program us)) (prog_comp_env (demo_camera_program us))
    (prog_comp_env_eq (demo_camera_program us)) (generated_camera_controller_definition us))
    as (co & Hlookup & Hmembers & Hattr & Hkind).
  exists co. split; [rewrite Henv; exact Hlookup | rewrite Hmembers; reflexivity].
Qed.

Lemma generated_camera_pressed_read_executes : forall us ge k e le m controller pressed,
  genv_cenv ge = prog_comp_env (demo_camera_program us) ->
  le ! C._t'65 = Some (Vptr controller Ptrofs.zero) ->
  Mem.load Mint16unsigned m controller 18 = Some (Vint pressed) ->
  demo_gameplay_dynamic_context us k ->
  exists after,
    demo_gameplay_consumption_step us ge
      (State (demo_camera_update us) demo_camera_pressed_read k e le m) after
      controller Ptrofs.zero C._buttonPressed (Vint pressed).
Proof.
  intros us ge k e le m controller pressed Henv Hptr Hload Hcontext.
  destruct (generated_camera_pressed_layout us ge Henv) as (co & Hco & Hoffset).
  apply demo_gameplay_read_constructs_actual_step.
  exists (demo_camera_update us), C._t'66,
    (Etempvar C._t'65 (tptr (Tstruct C._Controller noattr))), tushort, k, e, le, m.
  split; [reflexivity |]. split.
  - unfold demo_controller_read_field. do 6 right. split; reflexivity.
  - split; [exact Hcontext |]. split; [apply eval_Etempvar; exact Hptr |].
    eapply eval_Elvalue.
    + eapply eval_Efield_struct with (co := co) (delta := 18) (bf := Full).
      * eapply eval_Elvalue with (loc := controller) (ofs := Ptrofs.zero) (bf := Full).
        -- apply eval_Ederef. apply eval_Etempvar. exact Hptr.
        -- apply deref_loc_copy. reflexivity.
      * reflexivity.
      * exact Hco.
      * exact Hoffset.
    + apply deref_loc_value with (chunk := Mint16unsigned); [reflexivity |].
      change (Mem.load Mint16unsigned m controller 18 = Some (Vint pressed)). exact Hload.
Qed.

(** This witness is deliberately local: actual generated camera load and
    checked Controller layout, a genuinely readable allocated memory, an
    original generated basic-update return continuation, and a real Clight
    step.  It is NOT a normal-boot or authenticated-demo reachability witness. *)
Theorem generated_local_gameplay_read_witness_us_jp : forall us,
  exists before after controller,
    demo_gameplay_consumption_step us (Clight.globalenv (demo_camera_program us))
      before after controller Ptrofs.zero C._buttonPressed (Vint Int.one).
Proof.
  intros us.
  destruct (Mem.alloc Mem.empty 0 28) as [allocated controller] eqn:Halloc.
  assert (Haccess : Mem.valid_access allocated Mint16unsigned controller 18 Writable).
  { eapply Mem.valid_access_implies with (p1 := Freeable).
    - eapply (Mem.valid_access_alloc_same _ _ _ _ _ Halloc); cbn; try lia.
      exists 9. reflexivity.
    - constructor. }
  destruct (Mem.valid_access_store allocated Mint16unsigned controller 18 (Vint Int.one) Haccess)
    as [m Hstore].
  assert (Hload : Mem.load Mint16unsigned m controller 18 = Some (Vint Int.one)).
  { rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore). reflexivity. }
  set (k := Kcall None (demo_basic_update us) empty_env (PTree.empty val) Kstop).
  assert (Hcontext : demo_gameplay_dynamic_context us k).
  { unfold k. eapply demo_dynamic_update_anchor with (base := Kstop).
    - right; left; reflexivity.
    - apply generated_basic_camera_update_context. }
  destruct (generated_camera_pressed_read_executes us
    (Clight.globalenv (demo_camera_program us)) k empty_env
    (PTree.set C._t'65 (Vptr controller Ptrofs.zero) (PTree.empty val)) m controller Int.one)
    as [after Hread].
  - reflexivity.
  - apply PTree.gss.
  - exact Hload.
  - exact Hcontext.
  - eexists; exists after, controller. exact Hread.
Qed.

Definition demo_gameplay_consumption_observation_claim : Prop :=
  (demo_find_pressed_load (fn_body us_camera.f_update_camera) = Some demo_camera_pressed_read /\
   demo_find_pressed_load (fn_body jp_camera.f_update_camera) = Some demo_camera_pressed_read) /\
  (forall us, exists before after controller,
    demo_gameplay_consumption_step us (Clight.globalenv (demo_camera_program us))
      before after controller Ptrofs.zero C._buttonPressed (Vint Int.one)) /\
  (forall us prog h i controller offset field value,
    (i < history_length h)%nat ->
    demo_gameplay_read_state us (Clight.globalenv prog) (history_state h i)
      controller offset field value ->
    demo_gameplay_consumption_observation us prog h i controller offset field value).

Theorem generated_gameplay_consumption_observation_us_jp :
  demo_gameplay_consumption_observation_claim.
Proof.
  split; [exact generated_camera_pressed_read_hook_us_jp |].
  split; [exact generated_local_gameplay_read_witness_us_jp |].
  exact demo_history_read_is_consumption.
Qed.

(** Coverage remains a separate primary obligation: the missing Mario and
    object-helper units, embedded/non-normalized reads, and every other reached
    gameplay update route must be covered by the eventual full statement.
    This definition's current root inventory is not asserted exhaustive. *)
