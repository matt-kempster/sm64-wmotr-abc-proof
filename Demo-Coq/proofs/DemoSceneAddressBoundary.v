From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Events Globalenvs Integers Maps Memory Values.
From Demo.Generated Require Import us_geo_layout jp_geo_layout us_surface_load
  jp_surface_load us_memory jp_memory.
From Demo.Proofs Require Import DemoNumericAddressExecution DemoNumericDispatchExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module SG := us_geo_layout.
Module ST := us_surface_load.

(** This module identifies an obstruction of the current ordinary-Clight
    address representation. It does not prove that retail scene construction
    fails, that gameplay is unreachable on hardware, or that no desync occurs.
    No alternate step or numeric dereference rule is introduced. *)
Fixpoint scene_address_sequence_tail (n : nat) (s : statement) : statement :=
 match n, s with
 | O, _ => s
 | S n', Ssequence _ tail => scene_address_sequence_tail n' tail
 | _, _ => Sskip
 end.

Definition scene_geometry_segment_call body : statement :=
 match scene_address_sequence_tail 6 body with
 | Ssequence (Ssequence call _) _ => call | _ => Sskip end.
Definition scene_geometry_segment_store body : statement :=
 match scene_address_sequence_tail 6 body with
 | Ssequence (Ssequence _ store) _ => store | _ => Sskip end.
Definition scene_geometry_loop body : statement :=
 match scene_address_sequence_tail 10 body with
 | Ssequence (Sloop loop _) _ => loop | _ => Sskip end.
Definition scene_geometry_opcode_statement body : statement :=
 match scene_geometry_loop body with
 | Ssequence _ (Ssequence _ (Ssequence read _)) => read | _ => Sskip end.
Definition scene_geometry_opcode_expression : expr :=
 Ederef
   (Ebinop Oadd (Etempvar SG._t'3 (tptr tuchar))
     (Econst_int (Int.repr 0) tint) (tptr tuchar)) tuchar.

Definition scene_terrain_loop body : statement :=
 match scene_address_sequence_tail 7 body with
 | Ssequence (Sloop loop _) _ => loop | _ => Sskip end.
Definition scene_terrain_type_statement body : statement :=
 match scene_terrain_loop body with
 | Ssequence _ (Ssequence (Ssequence _ (Ssequence read _)) _) => read | _ => Sskip end.
Definition scene_terrain_type_expression : expr :=
 Ederef (Etempvar ST._t'10 (tptr tshort)) tshort.

Definition scene_geometry_function (us : bool) : function :=
 if us then SG.f_process_geo_layout else jp_geo_layout.f_process_geo_layout.
Definition scene_terrain_function (us : bool) : function :=
 if us then ST.f_load_area_terrain else jp_surface_load.f_load_area_terrain.

Lemma generated_scene_geometry_call_and_store_us_jp : forall us,
 scene_geometry_segment_call (fn_body (scene_geometry_function us)) =
   Scall (Some SG._t'1)
     (Evar SG._segmented_to_virtual (Tfunction ((tptr tvoid) :: nil) (tptr tvoid) cc_default))
     [Etempvar SG._segptr (tptr tvoid)] /\
 scene_geometry_segment_store (fn_body (scene_geometry_function us)) =
   Sassign (Evar SG._gGeoLayoutCommand (tptr tuchar)) (Etempvar SG._t'1 (tptr tvoid)).
Proof. intros []; split; reflexivity. Qed.

Lemma generated_scene_geometry_opcode_us_jp : forall us,
 scene_geometry_opcode_statement (fn_body (scene_geometry_function us)) =
   Sset SG._t'4 scene_geometry_opcode_expression.
Proof. intros []; reflexivity. Qed.

Lemma generated_scene_terrain_type_read_us_jp : forall us,
 scene_terrain_type_statement (fn_body (scene_terrain_function us)) =
   Sset ST._t'11 scene_terrain_type_expression.
Proof. intros []; reflexivity. Qed.

Lemma generated_scene_terrain_argument_copy_us_jp : forall us,
 match fn_body (scene_terrain_function us) with
 | Ssequence first _ => first | _ => Sskip end =
 Sassign (Evar ST._data (tptr tshort)) (Etempvar ST._data (tptr tshort)).
Proof. intros []; reflexivity. Qed.

(** Numeric pointer addition is permitted by this 32-bit target and still
    yields Vint. The subsequent real Ederef requires Vptr. *)
Lemma scene_numeric_geometry_expression_cannot_evaluate :
 forall ge e le m address value,
 le ! SG._t'3 = Some (Vint address) ->
 ~ eval_expr ge e le m scene_geometry_opcode_expression value.
Proof.
 intros ge e le m address value Hbinding Hexpr.
 unfold scene_geometry_opcode_expression in Hexpr.
 inversion Hexpr; subst.
 match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
   inversion Hlv; subst end.
 match goal with Hptr : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
   inversion Hptr; subst end.
 all: try match goal with Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion Hlv end.
 match goal with Htemp : eval_expr _ _ _ _ (Etempvar _ _) ?loaded |- _ =>
   pose proof (demo_eval_temp_binding _ _ _ _ _ _ _ Htemp) as Hget;
   assert (loaded = Vint address) by congruence; subst loaded end.
 match goal with Hconstant : eval_expr _ _ _ _ (Econst_int _ _) ?loaded |- _ =>
   pose proof (demo_eval_const_value _ _ _ _ _ _ _ Hconstant); subst loaded end.
 match goal with Hsem : sem_binary_operation _ Oadd (Vint address) _ _ _ _ = Some _ |- _ =>
   cbn [sem_binary_operation sem_add sem_add_ptr_int] in Hsem; discriminate end.
Qed.

Lemma scene_numeric_terrain_expression_cannot_evaluate :
 forall ge e le m address value,
 le ! ST._t'10 = Some (Vint address) ->
 ~ eval_expr ge e le m scene_terrain_type_expression value.
Proof.
 intros ge e le m address value Hbinding.
 unfold scene_terrain_type_expression.
 eapply demo_numeric_command_pointer_cannot_dereference; exact Hbinding.
Qed.

Theorem generated_scene_geometry_numeric_read_stuck_us_jp :
 forall us ge e le m k address,
 le ! SG._t'3 = Some (Vint address) ->
 ~ exists trace after, Clight.step2 ge
   (State (scene_geometry_function us)
     (scene_geometry_opcode_statement (fn_body (scene_geometry_function us))) k e le m)
   trace after.
Proof.
 intros us ge e le m k address Hbinding (trace & after & Hstep).
 rewrite generated_scene_geometry_opcode_us_jp in Hstep.
 unfold Clight.step2 in Hstep. inversion Hstep; subst.
 all: try solve [intuition discriminate].
 all: eapply scene_numeric_geometry_expression_cannot_evaluate; eassumption.
Qed.

Theorem generated_scene_terrain_numeric_read_stuck_us_jp :
 forall us ge e le m k address,
 le ! ST._t'10 = Some (Vint address) ->
 ~ exists trace after, Clight.step2 ge
   (State (scene_terrain_function us)
     (scene_terrain_type_statement (fn_body (scene_terrain_function us))) k e le m)
   trace after.
Proof.
 intros us ge e le m k address Hbinding (trace & after & Hstep).
 rewrite generated_scene_terrain_type_read_us_jp in Hstep.
 unfold Clight.step2 in Hstep. inversion Hstep; subst.
 all: try solve [intuition discriminate].
 all: eapply scene_numeric_terrain_expression_cannot_evaluate; eassumption.
Qed.

Lemma scene_numeric_segment_result_nonzero : forall base address,
 demo_n64_virtual_address base address <> Int.zero.
Proof.
 intros base address Hzero.
 pose proof (f_equal (fun integer => Int.testbit integer 31) Hzero) as Hbit.
 unfold demo_n64_virtual_address in Hbit.
 rewrite Int.bits_or in Hbit by (change (0 <= 31 < 32); lia).
 change (orb (Int.testbit (Int.add base (demo_n64_segment_offset address)) 31) true = false) in Hbit.
 rewrite orb_true_r in Hbit. discriminate.
Qed.

(** The real helper executes numerically and returns a nonzero numeric
    address. Supplying that returned value to either selected builder load
    still cannot construct the original-Clight field/opcode evaluation.
    This is a conditional local composition, not a full-builder trace. *)
Definition demo_scene_numeric_helper_read_claim : Prop :=
 forall (ge : Clight.genv) m table address base,
 Genv.find_symbol ge us_memory._sSegmentTable = Some table ->
 Mem.load Mint32 m table (demo_n64_table_offset address) = Some (Vint base) ->
 eval_funcall function_entry2 ge m (Internal us_memory.f_segmented_to_virtual)
   [Vint address] E0 m (Vint (demo_n64_virtual_address base address)) /\
 demo_n64_virtual_address base address <> Int.zero /\
 (forall e le value,
   le ! SG._t'3 = Some (Vint (demo_n64_virtual_address base address)) ->
   ~ eval_expr ge e le m scene_geometry_opcode_expression value) /\
 (forall e le value,
   le ! ST._t'10 = Some (Vint (demo_n64_virtual_address base address)) ->
   ~ eval_expr ge e le m scene_terrain_type_expression value).

Theorem generated_scene_numeric_helper_and_read_boundary :
 demo_scene_numeric_helper_read_claim.
Proof.
 intros ge m table address base Htable Hbase.
 split; [eapply generated_demo_numeric_segment_executes; eassumption |].
 split; [apply scene_numeric_segment_result_nonzero |].
 split; intros; [eapply scene_numeric_geometry_expression_cannot_evaluate |
   eapply scene_numeric_terrain_expression_cannot_evaluate]; eassumption.
Qed.

Definition demo_scene_address_boundary_claim_us_jp : Prop :=
 (forall us,
   scene_geometry_segment_call (fn_body (scene_geometry_function us)) =
     Scall (Some SG._t'1)
       (Evar SG._segmented_to_virtual (Tfunction ((tptr tvoid) :: nil) (tptr tvoid) cc_default))
       [Etempvar SG._segptr (tptr tvoid)] /\
   scene_geometry_segment_store (fn_body (scene_geometry_function us)) =
     Sassign (Evar SG._gGeoLayoutCommand (tptr tuchar)) (Etempvar SG._t'1 (tptr tvoid))) /\
 (forall us, scene_geometry_opcode_statement (fn_body (scene_geometry_function us)) =
   Sset SG._t'4 scene_geometry_opcode_expression) /\
 (forall us, scene_terrain_type_statement (fn_body (scene_terrain_function us)) =
   Sset ST._t'11 scene_terrain_type_expression) /\
 (forall us ge e le m k address,
   le ! SG._t'3 = Some (Vint address) ->
   ~ exists trace after, Clight.step2 ge
     (State (scene_geometry_function us)
       (scene_geometry_opcode_statement (fn_body (scene_geometry_function us))) k e le m)
     trace after) /\
 (forall us ge e le m k address,
   le ! ST._t'10 = Some (Vint address) ->
   ~ exists trace after, Clight.step2 ge
     (State (scene_terrain_function us)
       (scene_terrain_type_statement (fn_body (scene_terrain_function us))) k e le m)
     trace after) /\
 demo_scene_numeric_helper_read_claim /\
 demo_symbolic_segment_call_impossibility_claim us_memory.f_segmented_to_virtual /\
 demo_symbolic_segment_call_impossibility_claim jp_memory.f_segmented_to_virtual.

Theorem generated_scene_address_boundary_us_jp : demo_scene_address_boundary_claim_us_jp.
Proof.
 split; [exact generated_scene_geometry_call_and_store_us_jp |].
 split; [exact generated_scene_geometry_opcode_us_jp |].
 split; [exact generated_scene_terrain_type_read_us_jp |].
 split; [exact generated_scene_geometry_numeric_read_stuck_us_jp |].
 split; [exact generated_scene_terrain_numeric_read_stuck_us_jp |].
 split; [exact generated_scene_numeric_helper_and_read_boundary |].
 split; exact generated_demo_segmented_call_cannot_execute_symbolic_pointer.
Qed.
