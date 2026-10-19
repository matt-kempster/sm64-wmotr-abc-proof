(** The Teleporter Wrong Warp investigation's checked source boundary.

    The generated units below are VERSION_US and VERSION_JP Clight.  They
    do not model the PAL/Shindou Virtual Console emulator's continuation
    after an invalid load.  In particular, proving that a null [warpNode]
    has no Clight successor is NOT a proof that the retail emulator cannot
    continue with old register contents.

    The fading-teleporter gate checks exactly four action numbers.  It does
    not check [heldObj].  Therefore this source certificate alone is not an
    invariant saying that a reachable accepted action has no held object,
    and says nothing about platform/spawning displacement at the receiver.
    Those gameplay and emulator obligations remain open. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Clightdefs Cop Ctypes Events
  Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import
  us_interaction jp_interaction us_level_update jp_level_update
  us_mario jp_mario us_object_list_processor jp_object_list_processor
  us_platform_displacement.
From LessThanOneAPress.Proofs Require Import GameTypes.

Import ListNotations.
Local Open Scope Z_scope.

Module TWWI := us_interaction.
Module TWWL := us_level_update.

Definition tww_interaction_body (version : GameVersion) : statement :=
  fn_body (match version with
           | VersionUS => us_interaction.f_interact_warp
           | VersionJP => jp_interaction.f_interact_warp
           end).

Definition tww_delayed_warp_body (version : GameVersion) : statement :=
  fn_body (match version with
           | VersionUS => us_level_update.f_initiate_delayed_warp
           | VersionJP => jp_level_update.f_initiate_delayed_warp
           end).

(** This path selects the real action-test slice inside the generated
    fading-warp branch. A source change at that path changes the certificate. *)
Definition tww_fading_action_gate (version : GameVersion) : statement :=
  match tww_interaction_body version with
  | Ssequence
      (Ssequence _
        (Sifthenelse _
          (Ssequence _
            (Sifthenelse _ _
              (Ssequence _
                (Sifthenelse _ (Ssequence gate _) _)))) _)) _ => gate
  | _ => Sskip
  end.

Definition tww_action_equals (action_number : Z) : expr :=
  Ebinop Oeq (Etempvar TWWI._action tuint)
    (Econst_int (Int.repr action_number) tint) tint.

Definition tww_expected_fading_action_gate : statement :=
  Ssequence
    (Ssequence
      (Sifthenelse (tww_action_equals 205521409)
        (Sset TWWI._t'2 (Econst_int Int.one tint))
        (Sset TWWI._t'2 (Ecast (tww_action_equals 205521413) tbool)))
      (Sifthenelse (Etempvar TWWI._t'2 tint)
        (Sset TWWI._t'3 (Econst_int Int.one tint))
        (Sset TWWI._t'3 (Ecast (tww_action_equals 205521417) tbool))))
    (Sifthenelse (Etempvar TWWI._t'3 tint)
      (Sset TWWI._t'4 (Econst_int Int.one tint))
      (Sset TWWI._t'4 (Ecast (tww_action_equals 201359904) tbool))).

Theorem tww_generated_fading_action_gate_exact : forall version,
  tww_fading_action_gate version = tww_expected_fading_action_gate.
Proof. intros []; reflexivity. Qed.

(** Extract each equality-to-literal test from this exact source slice.
    This is a syntax inventory, not a theorem identifying held-object state. *)
Fixpoint tww_action_test_literals_expr (expression : expr) : list Int.int :=
  match expression with
  | Ebinop Oeq (Etempvar id _) (Econst_int number _) _ =>
      if Pos.eqb id TWWI._action then [number] else []
  | Ecast operand _ => tww_action_test_literals_expr operand
  | _ => []
  end.

Fixpoint tww_action_test_literals (body : statement) : list Int.int :=
  match body with
  | Sset _ expression => tww_action_test_literals_expr expression
  | Ssequence first second =>
      tww_action_test_literals first ++ tww_action_test_literals second
  | Sifthenelse test yes no =>
      tww_action_test_literals_expr test ++
        tww_action_test_literals yes ++ tww_action_test_literals no
  | _ => []
  end.

Definition tww_fading_action_numbers : list Int.int :=
  [Int.repr 205521409; Int.repr 205521413;
   Int.repr 205521417; Int.repr 201359904].

Theorem tww_generated_fading_action_inventory_exact : forall version,
  tww_action_test_literals (tww_fading_action_gate version) =
    tww_fading_action_numbers.
Proof. intros []; reflexivity. Qed.

(** Record all right-hand sides of a specified temporary assignment.  The
    mutual traversal includes switch alternatives, so the delayed-warp read
    is not identified by an informal comment or by a hand-written C model. *)
Fixpoint tww_set_expressions (id : ident) (body : statement) : list expr :=
  match body with
  | Sset target expression => if Pos.eqb target id then [expression] else []
  | Ssequence first second | Sloop first second =>
      tww_set_expressions id first ++ tww_set_expressions id second
  | Sifthenelse _ yes no =>
      tww_set_expressions id yes ++ tww_set_expressions id no
  | Sswitch _ alternatives => tww_labeled_set_expressions id alternatives
  | Slabel _ inner => tww_set_expressions id inner
  | _ => []
  end
with tww_labeled_set_expressions (id : ident) (alternatives : labeled_statements)
    : list expr :=
  match alternatives with
  | LSnil => []
  | LScons _ body rest =>
      tww_set_expressions id body ++ tww_labeled_set_expressions id rest
  end.

Definition tww_warp_node_pointer : expr :=
  Etempvar TWWL._warpNode (tptr (Tstruct TWWL._ObjectWarpNode noattr)).

Definition tww_warp_node_object : expr :=
  Ederef tww_warp_node_pointer (Tstruct TWWL._ObjectWarpNode noattr).

Definition tww_warp_node_record : expr :=
  Efield tww_warp_node_object TWWL._node (Tstruct TWWL._WarpNode noattr).

Definition tww_destination_level_read : expr :=
  Efield tww_warp_node_record TWWL._destLevel tuchar.

Definition tww_destination_read_statement : statement :=
  Sset TWWL._t'8 tww_destination_level_read.

Theorem tww_generated_destination_read_exact : forall version,
  tww_set_expressions TWWL._t'8 (tww_delayed_warp_body version) =
    [tww_destination_level_read].
Proof. intros []; reflexivity. Qed.

(** The music decision reads the missing node even before the delayed-warp
    suffix.  Select its first statement immediately after the generated
    lookup-and-pointer-copy prefix, preserving this earlier obstruction. *)
Definition tww_music_first_destination_statement version : statement :=
  match fn_body
    (match version with
     | VersionUS => us_level_update.f_music_changed_through_warp
     | VersionJP => jp_level_update.f_music_changed_through_warp
     end) with
  | Ssequence _ (Ssequence (Ssequence first _) _) => first
  | _ => Sskip
  end.

Definition tww_music_destination_temp version : ident :=
  match version with
  | VersionUS => us_level_update._t'21
  | VersionJP => jp_level_update._t'16
  end.

Theorem tww_generated_music_first_destination_read_exact : forall version,
  tww_music_first_destination_statement version =
    Sset (tww_music_destination_temp version) tww_destination_level_read.
Proof. intros []; reflexivity. Qed.

(** The first semantic obstruction is before a load can return any byte:
    Clight's dereference constructor requires a block pointer, whereas a
    source null pointer is represented by [Vint Int.zero] on this target. *)
Lemma tww_null_node_object_has_no_value : forall ge e le memory,
  le ! TWWL._warpNode = Some (Vint Int.zero) ->
  forall value, ~ eval_expr ge e le memory tww_warp_node_object value.
Proof.
  intros ge e le memory Hnull value Hread.
  unfold tww_warp_node_object in Hread.
  inversion Hread; subst.
  match goal with
  | Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
      inversion Hl; subst
  end.
  match goal with
  | Hp : eval_expr _ _ _ _ tww_warp_node_pointer (Vptr _ _) |- _ =>
      unfold tww_warp_node_pointer in Hp;
      inversion Hp; subst; try congruence;
      match goal with
      | Hbad : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
          inversion Hbad
      end
  end.
Qed.

Lemma tww_field_of_unreadable_expression_has_no_value :
  forall ge e le memory base field field_type,
    (forall value, ~ eval_expr ge e le memory base value) ->
    forall value,
      ~ eval_expr ge e le memory (Efield base field field_type) value.
Proof.
  intros ge e le memory base field field_type Hbase value Hread.
  inversion Hread; subst.
  match goal with
  | Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      inversion Hl; subst; eapply Hbase; eassumption
  end.
Qed.

Theorem tww_null_destination_read_has_no_value : forall ge e le memory,
  le ! TWWL._warpNode = Some (Vint Int.zero) ->
  forall value, ~ eval_expr ge e le memory tww_destination_level_read value.
Proof.
  intros ge e le memory Hnull.
  unfold tww_destination_level_read, tww_warp_node_record.
  apply tww_field_of_unreadable_expression_has_no_value.
  apply tww_field_of_unreadable_expression_has_no_value.
  now apply tww_null_node_object_has_no_value.
Qed.

Theorem tww_null_destination_statement_has_no_successor :
  forall ge function continuation e le memory,
    le ! TWWL._warpNode = Some (Vint Int.zero) ->
    forall trace after,
      ~ Clight.step2 ge
          (State function tww_destination_read_statement continuation e le memory)
          trace after.
Proof.
  intros ge function continuation e le memory Hnull trace after Hstep.
  unfold tww_destination_read_statement in Hstep.
  inversion Hstep; subst.
  - eapply tww_null_destination_read_has_no_value; eauto.
  - match goal with Hbad : _ \/ _ |- _ => destruct Hbad; discriminate end.
  - match goal with Hbad : _ \/ _ |- _ => destruct Hbad; discriminate end.
Qed.

Theorem tww_null_music_first_destination_statement_has_no_successor :
  forall version ge function continuation e le memory,
    le ! TWWL._warpNode = Some (Vint Int.zero) ->
    forall trace after,
      ~ Clight.step2 ge
          (State function (tww_music_first_destination_statement version)
            continuation e le memory) trace after.
Proof.
  intros version ge function continuation e le memory Hnull trace after Hstep.
  rewrite tww_generated_music_first_destination_read_exact in Hstep.
  inversion Hstep; subst.
  - eapply tww_null_destination_read_has_no_value; eauto.
  - match goal with Hbad : _ \/ _ |- _ => destruct Hbad; discriminate end.
  - match goal with Hbad : _ \/ _ |- _ => destruct Hbad; discriminate end.
Qed.

(** Item reset on the ordinary [init_mario] path is a separate fact from
    the teleporter's entry action check.  This inventory identifies the
    actual [heldObj = NULL] assignment in both generated versions. *)
Fixpoint tww_field_assignments (field : ident) (body : statement)
    : list statement :=
  match body with
  | Sassign (Efield _ target _) _ =>
      if Pos.eqb target field then [body] else []
  | Ssequence first second | Sloop first second =>
      tww_field_assignments field first ++ tww_field_assignments field second
  | Sifthenelse _ yes no =>
      tww_field_assignments field yes ++ tww_field_assignments field no
  | Sswitch _ alternatives => tww_labeled_field_assignments field alternatives
  | Slabel _ inner => tww_field_assignments field inner
  | _ => []
  end
with tww_labeled_field_assignments (field : ident)
    (alternatives : labeled_statements) : list statement :=
  match alternatives with
  | LSnil => []
  | LScons _ body rest =>
      tww_field_assignments field body ++
        tww_labeled_field_assignments field rest
  end.

Definition tww_init_mario_body version :=
  fn_body (match version with
           | VersionUS => us_mario.f_init_mario
           | VersionJP => jp_mario.f_init_mario
           end).

Definition tww_held_object_reset_statement : statement :=
  Sassign
    (Efield
      (Ederef (Etempvar us_mario._t'90
        (tptr (Tstruct us_mario._MarioState noattr)))
        (Tstruct us_mario._MarioState noattr))
      us_mario._heldObj (tptr (Tstruct us_mario._Object noattr)))
    (Ecast (Econst_int Int.zero tint) (tptr tvoid)).

Theorem tww_generated_init_mario_held_object_reset_exact : forall version,
  tww_field_assignments us_mario._heldObj (tww_init_mario_body version) =
    [tww_held_object_reset_statement].
Proof. intros []; reflexivity. Qed.

(** The interaction handler itself has no direct [heldObj] write.  In
    particular, the four accepted actions cannot be silently identified
    with a proof that this memory field was read or cleared by the gate. *)
Theorem tww_generated_interaction_has_no_direct_held_object_write :
  forall version,
    tww_field_assignments us_mario._heldObj (tww_interaction_body version) = [].
Proof. intros []; reflexivity. Qed.

Fixpoint tww_drop_sequence_prefix (count : nat) (body : statement)
    : statement :=
  match count, body with
  | S rest, Ssequence _ tail => tww_drop_sequence_prefix rest tail
  | _, _ => body
  end.

Fixpoint tww_direct_call_count (callee : ident) (body : statement) : nat :=
  match body with
  | Scall _ (Evar called _) _ => if Pos.eqb called callee then 1%nat else 0%nat
  | Ssequence first second | Sloop first second =>
      (tww_direct_call_count callee first + tww_direct_call_count callee second)%nat
  | Sifthenelse _ yes no =>
      (tww_direct_call_count callee yes + tww_direct_call_count callee no)%nat
  | Sswitch _ alternatives => tww_labeled_direct_call_count callee alternatives
  | Slabel _ inner => tww_direct_call_count callee inner
  | _ => 0%nat
  end
with tww_labeled_direct_call_count (callee : ident)
    (alternatives : labeled_statements) : nat :=
  match alternatives with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (tww_direct_call_count callee body +
        tww_labeled_direct_call_count callee rest)%nat
  end.

Definition tww_clear_platform_call : statement :=
  Scall None (Evar us_object_list_processor._clear_mario_platform
    (Tfunction [] tvoid cc_default)) [].

Definition tww_us_spawn_prefix_after_four_assignments : statement :=
  match tww_drop_sequence_prefix 4
    (fn_body us_object_list_processor.f_spawn_objects_from_info) with
  | Ssequence first _ => first
  | _ => Sskip
  end.

Definition tww_clear_platform_statement : statement :=
  Sassign
    (Evar us_platform_displacement._gMarioPlatform
      (tptr (Tstruct us_platform_displacement._Object noattr)))
    (Ecast (Econst_int Int.zero tint) (tptr tvoid)).

Theorem tww_generated_spawn_platform_reset_boundary :
  tww_us_spawn_prefix_after_four_assignments = tww_clear_platform_call /\
  tww_direct_call_count us_object_list_processor._clear_mario_platform
    (fn_body us_object_list_processor.f_spawn_objects_from_info) = 1%nat /\
  tww_direct_call_count us_object_list_processor._clear_mario_platform
    (fn_body jp_object_list_processor.f_spawn_objects_from_info) = 0%nat /\
  fn_body us_platform_displacement.f_clear_mario_platform =
    tww_clear_platform_statement.
Proof. repeat split; reflexivity. Qed.

Lemma tww_null_cast_has_null_value : forall ge e le memory value,
  eval_expr ge e le memory
    (Ecast (Econst_int Int.zero tint) (tptr tvoid)) value ->
  value = Vint Int.zero.
Proof.
  intros ge e le memory value Hread. inversion Hread; subst.
  - match goal with
    | Hconstant : eval_expr _ _ _ _ (Econst_int _ _) ?constant |- _ =>
        assert (constant = Vint Int.zero) as -> by
          (inversion Hconstant; subst; try reflexivity;
           match goal with
           | Hbad : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
               inversion Hbad
           end)
    end.
    match goal with Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
      change (Some (Vint Int.zero) = Some value) in Hcast;
      now inversion Hcast
    end.
  - match goal with
    | Hbad : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inversion Hbad
    end.
Qed.

(** Executing the generated clear statement stores a null pointer in the
    global's actual block and makes a null pointer load succeed immediately.
    This local postcondition does not exclude later platform reinstallation
    or identify which emulator transitions execute this function. *)
Definition tww_clear_platform_store_boundary : Prop :=
  forall ge function continuation le before trace after,
    Clight.step2 ge
      (State function tww_clear_platform_statement continuation
        (PTree.empty (block * type)) le before)
      trace
      (State function Sskip continuation
        (PTree.empty (block * type)) le after) ->
    exists platform_block,
      Genv.find_symbol ge us_platform_displacement._gMarioPlatform =
        Some platform_block /\
      Mem.store Mptr before platform_block 0 (Vint Int.zero) = Some after /\
      Mem.load Mptr after platform_block 0 = Some (Vint Int.zero).

Theorem tww_generated_clear_platform_stores_null :
  tww_clear_platform_store_boundary.
Proof.
  intros ge function continuation le before trace after Hstep.
  unfold tww_clear_platform_statement in Hstep.
  inversion Hstep; subst.
  - match goal with
    | Hread : eval_expr _ _ _ _
        (Ecast (Econst_int Int.zero tint) (tptr tvoid)) ?read |- _ =>
        assert (read = Vint Int.zero) as -> by
          (eapply tww_null_cast_has_null_value; exact Hread)
    end.
    match goal with Hcast : sem_cast _ _ _ _ = Some ?cast |- _ =>
      change (Some (Vint Int.zero) = Some cast) in Hcast;
      inversion Hcast; subst
    end.
    match goal with
    | Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
        inversion Hl; subst; try (rewrite PTree.gempty in *; discriminate)
    end.
    match goal with
    | Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
        inversion Ha; subst; try discriminate
    end.
    match goal with Hmode : access_mode _ = By_value _ |- _ =>
      cbn [access_mode] in Hmode; inversion Hmode; subst
    end.
    match goal with Hstore : Mem.storev _ _ _ _ = Some after |- _ =>
      pose proof Hstore as Hstored
    end.
    cbn [Mem.storev] in Hstored.
    change (Mem.store Mptr before loc 0 (Vint Int.zero) = Some after) in Hstored.
    exists loc. split; [assumption|]. split; [exact Hstored|].
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hstored). reflexivity.
  - match goal with Hbad : _ \/ _ |- _ => destruct Hbad; discriminate end.
Qed.

Definition tww_generated_us_jp_source_and_null_boundary : Prop :=
  (forall version,
    tww_fading_action_gate version = tww_expected_fading_action_gate /\
    tww_action_test_literals (tww_fading_action_gate version) =
      tww_fading_action_numbers /\
    tww_set_expressions TWWL._t'8 (tww_delayed_warp_body version) =
      [tww_destination_level_read] /\
    tww_music_first_destination_statement version =
      Sset (tww_music_destination_temp version) tww_destination_level_read) /\
  (forall ge function continuation e le memory,
    le ! TWWL._warpNode = Some (Vint Int.zero) ->
    forall trace after,
      ~ Clight.step2 ge
          (State function tww_destination_read_statement continuation e le memory)
          trace after) /\
  (forall version ge function continuation e le memory,
    le ! TWWL._warpNode = Some (Vint Int.zero) ->
    forall trace after,
      ~ Clight.step2 ge
          (State function (tww_music_first_destination_statement version)
            continuation e le memory) trace after) /\
  (forall version,
    tww_field_assignments us_mario._heldObj (tww_init_mario_body version) =
      [tww_held_object_reset_statement] /\
    tww_field_assignments us_mario._heldObj (tww_interaction_body version) = []) /\
  (tww_us_spawn_prefix_after_four_assignments = tww_clear_platform_call /\
   tww_direct_call_count us_object_list_processor._clear_mario_platform
     (fn_body us_object_list_processor.f_spawn_objects_from_info) = 1%nat /\
   tww_direct_call_count us_object_list_processor._clear_mario_platform
     (fn_body jp_object_list_processor.f_spawn_objects_from_info) = 0%nat /\
   fn_body us_platform_displacement.f_clear_mario_platform =
     tww_clear_platform_statement) /\
  tww_clear_platform_store_boundary.

Theorem tww_generated_us_jp_source_and_null_boundary_checked :
  tww_generated_us_jp_source_and_null_boundary.
Proof.
  split.
  - intros version. split.
    + exact (tww_generated_fading_action_gate_exact version).
    + split.
      * exact (tww_generated_fading_action_inventory_exact version).
      * split.
        -- exact (tww_generated_destination_read_exact version).
        -- exact (tww_generated_music_first_destination_read_exact version).
  - split.
    + exact tww_null_destination_statement_has_no_successor.
    + split.
      * exact tww_null_music_first_destination_statement_has_no_successor.
      * split.
        -- intros version. split.
           ++ exact (tww_generated_init_mario_held_object_reset_exact version).
           ++ exact (tww_generated_interaction_has_no_direct_held_object_write version).
        -- split.
           ++ exact tww_generated_spawn_platform_reset_boundary.
           ++ exact tww_generated_clear_platform_stores_null.
Qed.
