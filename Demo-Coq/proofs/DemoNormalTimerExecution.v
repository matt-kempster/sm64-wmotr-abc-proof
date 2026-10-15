From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update.
From Demo.Proofs Require Import DemoStartExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module T := us_level_update.

(** Select the real timer block between check_instant_warp and
    area_update_objects in the generated normal frame. *)
Definition normal_timer_statement (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _ (Ssequence _ (Ssequence timer _))) => timer
  | _ => Sskip
  end.

Lemma generated_normal_timer_statement_identical_us_jp :
  normal_timer_statement (fn_body T.f_play_mode_normal) =
  normal_timer_statement (fn_body jp_level_update.f_play_mode_normal).
Proof. reflexivity. Qed.

Lemma generated_normal_timer_selector_is_nonempty :
  normal_timer_statement (fn_body T.f_play_mode_normal) <> Sskip.
Proof. discriminate. Qed.

Ltac timer_reduce :=
  first
  [match goal with
   | H : Int.cmp Clt ?tick (Int.repr 17999) = ?choice |- _ = ?out =>
     change (Some (Val.of_bool (Int.cmp Clt tick (Int.repr 17999))) = out);
     rewrite H; reflexivity
   end
  |reflexivity].

Ltac timer_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
    eapply eval_Etempvar; repeat rewrite PTree.gsspec;
    cbn -[Int.eq Int.cmp Int.add Int.zero_ext]; reflexivity
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
    eapply eval_Ebinop; [timer_expr | timer_expr | timer_reduce]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
    eapply eval_Ecast; [timer_expr | timer_reduce]
  | _ => first [demo_expr | match goal with |- ?g => idtac "TIMER EXPR FAILED" g; fail 1000 end]
  end.

Ltac timer_bool :=
  lazymatch goal with
  | |- bool_val (Vint ?running) _ _ = Some ?choice =>
    change (Some (negb (Int.eq running Int.zero)) = Some choice);
    match goal with
    | H : Int.eq running Int.zero = _ |- _ => rewrite H; reflexivity
    end
  end.

Ltac timer_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [timer_stmt | timer_stmt]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse (Etempvar T._t'14 _) _ _) _ _ _ _ =>
    match goal with
    | H : Mem.load Mint8signed _ _ 0 = Some (Vint ?running),
      Hzero : Int.eq ?running Int.zero = ?choice |- _ =>
      eapply exec_Sifthenelse with (v1 := Vint running) (b := negb choice);
        [timer_expr | timer_bool | cbn; timer_stmt]
    | |- ?g => idtac "TIMER RUNNING GUARD FAILED" g; fail 1000
    end
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
    first
    [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
      [timer_expr | reflexivity | timer_stmt]
    |eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
      [timer_expr | reflexivity | timer_stmt]]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; timer_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
    eapply exec_Sassign;
      [demo_lvalue | timer_expr | reflexivity |
       eapply assign_loc_value; [reflexivity | cbn -[Int.add Int.zero_ext]; eassumption]]
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => apply exec_Sskip
  | |- ?g => idtac "TIMER STATEMENT FAILED" g; fail 1000
  end.

Ltac timer_actual_us :=
  lazymatch goal with
  | |- exec_stmt ?entry ?ge ?env ?le ?m _ ?trace ?le' ?m' ?out =>
    change (exec_stmt entry ge env le m
      (normal_timer_statement (fn_body T.f_play_mode_normal)) trace le' m' out)
  end;
  cbn [normal_timer_statement T.f_play_mode_normal fn_body]; timer_stmt.

Definition demo_normal_timer_execution_claim : Prop :=
  forall (ge : Clight.genv) le m running_global running hud hud_co tick,
    Genv.find_symbol ge T._sTimerRunning = Some running_global ->
    Mem.load Mint8signed m running_global 0 = Some (Vint running) ->
    Genv.find_symbol ge T._gHudDisplay = Some hud ->
    (genv_cenv ge) ! T._HudDisplay = Some hud_co ->
    field_offset (genv_cenv ge) T._timer (co_members hud_co) = OK (12, Full) ->
    Mem.load Mint16unsigned m hud 12 = Some (Vint tick) ->
    Mem.valid_access m Mint16unsigned hud 12 Writable ->
    exists le' m',
      (forall us : bool, exec_stmt function_entry2 ge empty_env le m
        (normal_timer_statement (fn_body
          (if us then T.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
        E0 le' m' Out_normal) /\
      (if Int.eq running Int.zero then m' = m
       else if Int.cmp Clt tick (Int.repr 17999)
       then Mem.store Mint16unsigned m hud 12
         (Vint (Int.zero_ext 16 (Int.add tick Int.one))) = Some m'
       else m' = m) /\
      (forall chunk b ofs, b <> hud -> Mem.load chunk m' b ofs = Mem.load chunk m b ofs) /\
      (forall chunk b ofs permission, Mem.valid_access m chunk b ofs permission ->
         Mem.valid_access m' chunk b ofs permission).

Theorem generated_normal_timer_executes_us_jp : demo_normal_timer_execution_claim.
Proof.
  intros ge le m running_global running hud hud_co tick
    Hrunning_symbol Hrunning Hhud_symbol Hhud_co Htimer_offset Htick Hwritable.
  destruct (Int.eq running Int.zero) eqn:Hrunning_zero.
  - eexists; exists m; split.
    + intro us; destruct us; timer_actual_us.
    + split; [reflexivity | split].
      * intros; reflexivity.
      * intros; assumption.
  - destruct (Int.cmp Clt tick (Int.repr 17999)) eqn:Hbelow.
    + destruct (Mem.valid_access_store m Mint16unsigned hud 12
        (Vint (Int.zero_ext 16 (Int.add tick Int.one))) Hwritable) as [after Hstore].
      eexists; exists after; split.
      * intro us; destruct us; timer_actual_us.
      * split; [exact Hstore | split].
        -- intros chunk b ofs Houtside.
           rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore) by (left; congruence).
           reflexivity.
        -- intros chunk b ofs permission Haccess.
           eapply Mem.store_valid_access_1; eassumption.
    + eexists; exists m; split.
      * intro us; destruct us; timer_actual_us.
      * split; [reflexivity | split].
        -- intros; reflexivity.
        -- intros; assumption.
Qed.

(** The scheduling fields are real globals.  A HUD tick cannot erase the
    operation/timer established by the actual Demo Next scheduler. *)
Definition demo_normal_timer_pending_start_claim : Prop :=
  forall (ge : Clight.genv) le m running_global running hud hud_co tick
      operation pending_timer,
    Genv.find_symbol ge T._sTimerRunning = Some running_global ->
    Mem.load Mint8signed m running_global 0 = Some (Vint running) ->
    Genv.find_symbol ge T._gHudDisplay = Some hud ->
    (genv_cenv ge) ! T._HudDisplay = Some hud_co ->
    field_offset (genv_cenv ge) T._timer (co_members hud_co) = OK (12, Full) ->
    Mem.load Mint16unsigned m hud 12 = Some (Vint tick) ->
    Mem.valid_access m Mint16unsigned hud 12 Writable ->
    Genv.find_symbol ge T._sDelayedWarpOp = Some operation ->
    Genv.find_symbol ge T._sDelayedWarpTimer = Some pending_timer ->
    operation <> hud -> pending_timer <> hud ->
    Mem.load Mint16signed m operation 0 = Some (Vint (Int.repr 22)) ->
    Mem.load Mint16signed m pending_timer 0 = Some (Vint (Int.repr 20)) ->
    exists le' m',
      (forall us : bool, exec_stmt function_entry2 ge empty_env le m
        (normal_timer_statement (fn_body
          (if us then T.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
        E0 le' m' Out_normal) /\
      Mem.load Mint16signed m' operation 0 = Some (Vint (Int.repr 22)) /\
      Mem.load Mint16signed m' pending_timer 0 = Some (Vint (Int.repr 20)).

Theorem generated_normal_timer_preserves_pending_start :
  demo_normal_timer_pending_start_claim.
Proof.
  intros ge le m running_global running hud hud_co tick operation pending_timer
    Hrunning_symbol Hrunning Hhud_symbol Hhud_co Htimer_offset Htick Hwritable
    Hop_symbol Hpending_symbol Hop_separate Hpending_separate Hop Hpending.
  destruct (generated_normal_timer_executes_us_jp ge le m running_global running
    hud hud_co tick Hrunning_symbol Hrunning Hhud_symbol Hhud_co Htimer_offset
    Htick Hwritable) as (le' & after & Hexec & Heffect & Hframe & Haccess).
  exists le', after; split; [exact Hexec | split].
  - rewrite Hframe by exact Hop_separate; exact Hop.
  - rewrite Hframe by exact Hpending_separate; exact Hpending.
Qed.

Definition demo_normal_timer_boundary_claim : Prop :=
  demo_normal_timer_execution_claim /\ demo_normal_timer_pending_start_claim.

Theorem generated_normal_timer_boundary_us_jp : demo_normal_timer_boundary_claim.
Proof.
  split.
  - exact generated_normal_timer_executes_us_jp.
  - exact generated_normal_timer_preserves_pending_start.
Qed.
