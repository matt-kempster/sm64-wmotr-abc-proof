(** Rank 9A's ordinary coin producers, authenticated against generated data.
    This is an initializer/source census, NOT an exhaustive live-motion proof.
    In particular the formation separation theorem exposes its offset bound;
    it does not assume that a source initializer is a reached object. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs Cop Ctypes Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions jp_behavior_actions us_behavior_data jp_behavior_data
  us_macro_special_objects jp_macro_special_objects
  us_object_helpers jp_object_helpers us_obj_behaviors_2 jp_obj_behaviors_2
  us_ssl_area2_macro jp_ssl_area2_macro.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes
  Area2Rank9AStarGeometry Area2Rank11GoombaInstaller.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Module R9CA := us_behavior_actions.
Module R9CJ := jp_behavior_actions.
Module R9CH := us_object_helpers.
Module R9CP := us_macro_special_objects.

Definition rank9ac_macro_data version := gvar_init (match version with
| VersionUS => us_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs
| VersionJP => jp_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs end).

Definition rank9ac_preset_data version := gvar_init (match version with
| VersionUS => us_macro_special_objects.v_sMacroObjectPresets
| VersionJP => jp_macro_special_objects.v_sMacroObjectPresets end).

(** Decode the actual macro tag, including its yaw bits, and resolve its
    behavior/parameter through the generated preset table. *)
Definition rank9ac_preset version record : option (ident * Z) :=
  match record with
  | tag :: _ =>
      match firstn 3 (skipn (3 * Z.to_nat (Z.land tag 511 - 31))
        (rank9ac_preset_data version)) with
      | [Init_addrof behavior offset; Init_int16 _; Init_int16 parameter] =>
          if Ptrofs.eq offset Ptrofs.zero
          then Some (behavior, Int.signed parameter) else None
      | _ => None end
  | _ => None end.

Definition rank9ac_records_for version behavior :=
  filter (fun record => match rank9ac_preset version record with
    | Some (found, _) => Pos.eqb found behavior | None => false end)
    (chunks5 (init_int16_values (rank9ac_macro_data version))).

Definition rank9ac_formation_records : list (list Z) :=
  [[16424; -2; 1774; 2794; 0]; [42; 2694; 850; -2889; 0];
   [16421; -210; 4521; -994; 0]; [41; 290; 4479; -940; 0]].

Theorem rank9ac_generated_formation_and_blue_census : forall version,
  rank9ac_records_for version R9CP._bhvCoinFormation = rank9ac_formation_records /\
  map (rank9ac_preset version) rank9ac_formation_records =
    [Some (R9CP._bhvCoinFormation, 16); Some (R9CP._bhvCoinFormation, 18);
     Some (R9CP._bhvCoinFormation, 0); Some (R9CP._bhvCoinFormation, 17)] /\
  rank9ac_records_for version R9CP._bhvHiddenBlueCoin =
    [[85; 0; 0; 2381; 0]; [85; 0; 100; 2381; 0]; [85; 0; 200; 2381; 0]] /\
  length (chunks5 (init_int16_values (rank9ac_macro_data version))) = 50%nat /\
  forallb (fun record => match rank9ac_preset version record with
    | Some _ => true | None => false end)
    (chunks5 (init_int16_values (rank9ac_macro_data version))) = true.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

(** A deliberately generous bound, allowing 640 units in BOTH horizontal
    coordinates independently. Stock rows/rings have smaller offsets. The
    live relative-transform/alias frame is not hidden in this arithmetic. *)
Theorem rank9ac_formation_separation_even_with_640_offset :
  forall tag x y z parameter dx dz,
    In [tag; x; y; z; parameter] rank9ac_formation_records ->
    -640 <= dx <= 640 -> -640 <= dz <= 640 ->
    ~ (-302 <= x + dx <= 302 /\ 1029 <= z + dz <= 1634).
Proof.
  intros tag x y z parameter dx dz Hin Hx Hz.
  cbn in Hin. repeat destruct Hin as [H | Hin]; try contradiction;
    inversion H; subst; lia.
Qed.

Theorem rank9ac_hidden_blue_initializers_are_not_near_shaft : forall version,
  forallb rank9a_coin_outside_expanded_shaft
    (rank9ac_records_for version R9CP._bhvHiddenBlueCoin) = true.
Proof. intros []; vm_compute; reflexivity. Qed.

(** These tempting alternative macro producers are absent, not merely far
    away. This does not itself prove an arbitrary foreign actor cannot enter
    through a different area/lifetime history. *)
Definition rank9ac_absent_macro_producers : list ident :=
  [R9CP._bhvSmallWhomp; R9CP._bhvSmallBully; R9CP._bhvBigBully;
   R9CP._bhvPokey; R9CP._bhvBreakableBox; R9CP._bhvBreakableBoxSmall;
   R9CP._bhvMovingBlueCoin; R9CP._bhvBlueCoinSliding].

Theorem rank9ac_no_alternative_macro_producer : forall version,
  forallb (fun behavior => match rank9ac_records_for version behavior with
    | [] => true | _ => false end) rank9ac_absent_macro_producers = true /\
  rank9ac_records_for version R9CP._bhvExclamationBox =
    [[98; -3536; 252; -3705; 0]; [98; -1242; 252; -3957; 0]] /\
  rank9ac_preset version [98; -3536; 252; -3705; 0] =
    Some (R9CP._bhvExclamationBox, 7) /\
  firstn 5 (skipn 35 (gvar_init (match version with
    | VersionUS => R9CA.v_sExclamationBoxContents
    | VersionJP => R9CJ.v_sExclamationBoxContents end))) =
    [Init_int8 (Int.repr 7); Init_int8 Int.zero; Init_int8 Int.zero;
     Init_int8 (Int.repr 212); Init_addrof R9CA._bhv1UpWalking Ptrofs.zero].
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

(** Exhaust all native bodies in the generated behavior-actions unit, not a
    hand-picked list of Whomp handlers. Other translation units and indirect
    reachability are not inferred from this direct-call census. *)
Definition rank9ac_native_callers callee
    (definitions : list (ident * globdef Clight.fundef type)) :=
  map fst (filter (fun entry => match snd entry with
    | Gfun (Internal body) => calls_ident_s callee (fn_body body)
    | _ => false end) definitions).

Theorem rank9ac_at_mario_coin_is_a_whomp_callsite : forall version,
  rank9ac_native_callers R9CH._cur_obj_spawn_loot_coin_at_mario_pos
    (match version with | VersionUS => R9CA.global_definitions
      | VersionJP => R9CJ.global_definitions end) = [R9CA._whomp_on_ground].
Proof. intros []; vm_compute; reflexivity. Qed.

(** Check ALL direct float/int raw-array writes of the fixed coin loops for
    X/Z indices 6 and 8. The calls must still receive their own live frames;
    absence of this syntactic store shape is not a memory-separation proof. *)
Definition rank9ac_fixed_coin_bodies version : list function := match version with
| VersionUS => [R9CA.f_bhv_yellow_coin_init; R9CA.f_bhv_yellow_coin_loop;
    R9CA.f_bhv_coin_formation_spawn_loop; R9CA.f_bhv_hidden_blue_coin_loop]
| VersionJP => [R9CJ.f_bhv_yellow_coin_init; R9CJ.f_bhv_yellow_coin_loop;
    R9CJ.f_bhv_coin_formation_spawn_loop; R9CJ.f_bhv_hidden_blue_coin_loop] end.

Theorem rank9ac_fixed_coin_loops_have_no_direct_xz_store : forall version,
  forallb (fun body => forallb (fun slot =>
    negb (assigns_array_slot_s R9CA._asF32 slot (fn_body body)) &&
    negb (assigns_array_slot_s R9CA._asS32 slot (fn_body body))) [6; 8])
    (rank9ac_fixed_coin_bodies version) = true.
Proof. intros []; vm_compute; reflexivity. Qed.

(** The normal regular-Goomba attack row contains only knockback/squish, not
    the huge-Goomba blue-coin handler. Its hitbox initializes ONE loot coin. *)
Theorem rank9ac_regular_goomba_loot_source : forall version,
  gvar_init (match version with
    | VersionUS => us_obj_behaviors_2.v_sGoombaHitbox
    | VersionJP => jp_obj_behaviors_2.v_sGoombaHitbox end) =
    rank11_goomba_hitbox_initializer /\
  firstn 6 (gvar_init (match version with
    | VersionUS => us_obj_behaviors_2.v_sGoombaAttackHandlers
    | VersionJP => jp_obj_behaviors_2.v_sGoombaAttackHandlers end)) =
    map (fun n => Init_int8 (Int.repr n)) [2; 2; 3; 3; 2; 2] /\
  firstn 6 (gvar_init (match version with
    | VersionUS => us_obj_behaviors_2.v_sEyerokHitbox
    | VersionJP => jp_obj_behaviors_2.v_sEyerokHitbox end)) =
    [Init_int32 (Int.repr 32768); Init_int8 Int.zero; Init_int8 Int.zero;
     Init_int8 (Int.repr 4); Init_int8 Int.zero; Init_int16 (Int.repr 150)].
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Definition rank9ac_yellow_loot_call : statement :=
  Scall None
    (Evar R9CH._obj_spawn_loot_coins (Tfunction
      [tptr (Tstruct R9CH._Object noattr); tint; tfloat; tptr tuint; tshort; tshort]
      tvoid cc_default))
    [Etempvar R9CH._obj (tptr (Tstruct R9CH._Object noattr));
     Etempvar R9CH._numCoins tint; Etempvar R9CH._baseVelY tfloat;
     Evar R9CH._bhvSingleCoinGetsSpawned (tarray tuint 0);
     Econst_int Int.zero tint; Econst_int (Int.repr 116) tint].

Theorem rank9ac_yellow_loot_has_no_spawn_jitter : forall version,
  fn_body (match version with
    | VersionUS => us_object_helpers.f_obj_spawn_loot_yellow_coins
    | VersionJP => jp_object_helpers.f_obj_spawn_loot_yellow_coins end) =
    rank9ac_yellow_loot_call.
Proof. intros []; reflexivity. Qed.

(** Exact behavior bytes: the native initializer is followed by normal coin
    physics (gravity -4, restitution -0.7) and the moving spawned-coin loop.
    Renaming the object's behavior identity to bhvYellowCoin in the native
    initializer must NOT be mistaken for selecting its stationary loop. *)
Definition rank9ac_spawned_coin_script : list init_data :=
  [Init_int32 (Int.repr 393216); Init_int32 (Int.repr 285278209);
   Init_int32 (Int.repr 553648128); Init_int32 (Int.repr 201326592);
   Init_addrof R9CA._bhv_spawned_coin_init Ptrofs.zero;
   Init_int32 (Int.repr 805306368); Init_int32 (Int.repr 2031216);
   Init_int32 (Int.repr (-4586520)); Init_int32 (Int.repr 65536200);
   Init_int32 Int.zero; Init_int32 (Int.repr 134217728);
   Init_int32 (Int.repr 201326592);
   Init_addrof R9CA._bhv_spawned_coin_loop Ptrofs.zero;
   Init_int32 (Int.repr 253362177); Init_int32 (Int.repr 150994944)].

Theorem rank9ac_spawned_coin_script_checked : forall version,
  gvar_init (match version with
    | VersionUS => us_behavior_data.v_bhvSingleCoinGetsSpawned
    | VersionJP => jp_behavior_data.v_bhvSingleCoinGetsSpawned end) =
    rank9ac_spawned_coin_script.
Proof. intros []; reflexivity. Qed.

Definition Rank9ACoinProducerSourceBoundary : Prop :=
  Rank11Area2GoombaRosterSourceShape /\
  (forall version,
    rank9ac_records_for version R9CP._bhvCoinFormation = rank9ac_formation_records /\
    rank9ac_records_for version R9CP._bhvHiddenBlueCoin =
      [[85; 0; 0; 2381; 0]; [85; 0; 100; 2381; 0]; [85; 0; 200; 2381; 0]]) /\
  (forall tag x y z parameter dx dz,
    In [tag; x; y; z; parameter] rank9ac_formation_records ->
    -640 <= dx <= 640 -> -640 <= dz <= 640 ->
    ~ (-302 <= x + dx <= 302 /\ 1029 <= z + dz <= 1634)) /\
  (forall version, fn_body (match version with
    | VersionUS => us_object_helpers.f_obj_spawn_loot_yellow_coins
    | VersionJP => jp_object_helpers.f_obj_spawn_loot_yellow_coins end) =
    rank9ac_yellow_loot_call) /\
  (forall version, gvar_init (match version with
    | VersionUS => us_behavior_data.v_bhvSingleCoinGetsSpawned
    | VersionJP => jp_behavior_data.v_bhvSingleCoinGetsSpawned end) =
    rank9ac_spawned_coin_script) /\
  (forall version,
    forallb (fun behavior => match rank9ac_records_for version behavior with
      | [] => true | _ => false end) rank9ac_absent_macro_producers = true /\
    rank9ac_records_for version R9CP._bhvExclamationBox =
      [[98; -3536; 252; -3705; 0]; [98; -1242; 252; -3957; 0]] /\
    rank9ac_preset version [98; -3536; 252; -3705; 0] =
      Some (R9CP._bhvExclamationBox, 7) /\
    firstn 5 (skipn 35 (gvar_init (match version with
      | VersionUS => R9CA.v_sExclamationBoxContents
      | VersionJP => R9CJ.v_sExclamationBoxContents end))) =
      [Init_int8 (Int.repr 7); Init_int8 Int.zero; Init_int8 Int.zero;
       Init_int8 (Int.repr 212); Init_addrof R9CA._bhv1UpWalking Ptrofs.zero]) /\
  (forall version,
    rank9ac_native_callers R9CH._cur_obj_spawn_loot_coin_at_mario_pos
      (match version with | VersionUS => R9CA.global_definitions
        | VersionJP => R9CJ.global_definitions end) = [R9CA._whomp_on_ground]) /\
  (forall version,
    forallb (fun body => forallb (fun slot =>
      negb (assigns_array_slot_s R9CA._asF32 slot (fn_body body)) &&
      negb (assigns_array_slot_s R9CA._asS32 slot (fn_body body))) [6; 8])
      (rank9ac_fixed_coin_bodies version) = true) /\
  (forall version,
    gvar_init (match version with
      | VersionUS => us_obj_behaviors_2.v_sGoombaHitbox
      | VersionJP => jp_obj_behaviors_2.v_sGoombaHitbox end) =
      rank11_goomba_hitbox_initializer /\
    firstn 6 (gvar_init (match version with
      | VersionUS => us_obj_behaviors_2.v_sGoombaAttackHandlers
      | VersionJP => jp_obj_behaviors_2.v_sGoombaAttackHandlers end)) =
      map (fun n => Init_int8 (Int.repr n)) [2; 2; 3; 3; 2; 2] /\
    firstn 6 (gvar_init (match version with
      | VersionUS => us_obj_behaviors_2.v_sEyerokHitbox
      | VersionJP => jp_obj_behaviors_2.v_sEyerokHitbox end)) =
      [Init_int32 (Int.repr 32768); Init_int8 Int.zero; Init_int8 Int.zero;
       Init_int8 (Int.repr 4); Init_int8 Int.zero; Init_int16 (Int.repr 150)]).

Theorem rank9ac_coin_producer_source_boundary_checked : Rank9ACoinProducerSourceBoundary.
Proof.
  split; [exact rank11_area2_goomba_roster_source_shape_checked |].
  split.
  - intro version. pose proof (rank9ac_generated_formation_and_blue_census version)
      as (Hformation & _ & Hblue & _). auto.
  - split; [exact rank9ac_formation_separation_even_with_640_offset |].
    split; [exact rank9ac_yellow_loot_has_no_spawn_jitter |].
    split; [exact rank9ac_spawned_coin_script_checked |].
    split; [exact rank9ac_no_alternative_macro_producer |].
    split; [exact rank9ac_at_mario_coin_is_a_whomp_callsite |].
    split; [exact rank9ac_fixed_coin_loops_have_no_direct_xz_store |
      exact rank9ac_regular_goomba_loot_source].
Qed.
