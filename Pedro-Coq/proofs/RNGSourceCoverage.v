From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From Pedro.Proofs Require Import GameTypes RNGEffectSyntax RNGSourceCatalogue.
Import ListNotations.

(** Syntactic writes include arbitrary right-hand sides, so a variable mask
    cannot disappear from the writer inventory. Pointer aliases and helper
    executions are separate semantic obligations. *)
Inductive field_write_occurs (field : ident) : statement -> Prop :=
| FieldWrite base ty rhs : field_write_occurs field (Sassign (Efield base field ty) rhs)
| FieldSeqLeft a b : field_write_occurs field a -> field_write_occurs field (Ssequence a b)
| FieldSeqRight a b : field_write_occurs field b -> field_write_occurs field (Ssequence a b)
| FieldIfLeft e a b : field_write_occurs field a -> field_write_occurs field (Sifthenelse e a b)
| FieldIfRight e a b : field_write_occurs field b -> field_write_occurs field (Sifthenelse e a b)
| FieldLoopLeft a b : field_write_occurs field a -> field_write_occurs field (Sloop a b)
| FieldLoopRight a b : field_write_occurs field b -> field_write_occurs field (Sloop a b)
| FieldSwitch e cases : field_write_occurs_cases field cases -> field_write_occurs field (Sswitch e cases)
| FieldLabel name body : field_write_occurs field body -> field_write_occurs field (Slabel name body)
with field_write_occurs_cases (field : ident) : labeled_statements -> Prop :=
| FieldCaseHead label body rest : field_write_occurs field body ->
    field_write_occurs_cases field (LScons label body rest)
| FieldCaseTail label body rest : field_write_occurs_cases field rest ->
    field_write_occurs_cases field (LScons label body rest).

Scheme field_write_occurs_ind' := Induction for field_write_occurs Sort Prop
with field_write_occurs_cases_ind' := Induction for field_write_occurs_cases Sort Prop.
Combined Scheme field_write_mutual from field_write_occurs_ind', field_write_occurs_cases_ind'.

Lemma field_write_inventory_complete :
  forall field,
    (forall body, field_write_occurs field body -> field_assignment field body = true) /\
    (forall cases, field_write_occurs_cases field cases -> field_assignment_cases field cases = true).
Proof.
  intro field. apply (field_write_mutual field
    (fun body _ => field_assignment field body = true)
    (fun cases _ => field_assignment_cases field cases = true));
    simpl; intros; try apply Pos.eqb_refl;
    repeat rewrite Bool.orb_true_iff; intuition.
Qed.

Lemma rng_source_body_member :
  forall version unit caller f,
    In (caller, Gfun (Internal f)) (prog_defs (rng_source_program version unit)) ->
    In (caller, f) (rng_source_bodies version unit).
Proof.
  intros version unit caller f Hin. unfold rng_source_bodies.
  apply in_flat_map. exists (caller, Gfun (Internal f)). split; [exact Hin |].
  simpl; auto.
Qed.

Theorem generated_computed_call_site_coverage_us_jp :
  forall version unit caller f target,
    In (caller, Gfun (Internal f)) (prog_defs (rng_source_program version unit)) ->
    call_occurs target (fn_body f) -> computed_call target = true ->
    In caller (expected_rng_computed_callers version unit).
Proof.
  intros version unit caller f target Hfunction Hcall Hcomputed.
  destruct (generated_rng_unit_catalogues_us_jp version unit) as [_ [_ [_ [Hinventory _]]]].
  rewrite <- Hinventory. unfold rng_computed_callers.
  apply in_map_iff. exists (caller, f). split; [reflexivity |].
  apply filter_In. split; [eapply rng_source_body_member; eauto |].
  simpl. apply existsb_exists. exists target. split; [|exact Hcomputed].
  eapply (proj1 call_expression_inventory_complete); eauto.
Qed.

Theorem generated_particle_field_write_coverage_us_jp :
  forall version unit caller f,
    In (caller, Gfun (Internal f)) (prog_defs (rng_source_program version unit)) ->
    field_write_occurs us_mario._particleFlags (fn_body f) ->
    In caller (expected_rng_particle_field_writers version unit).
Proof.
  intros version unit caller f Hfunction Hwrite.
  destruct (generated_rng_unit_catalogues_us_jp version unit) as [_ [_ [_ [_ [Hinventory _]]]]].
  rewrite <- Hinventory. unfold rng_particle_field_writers.
  apply in_map_iff. exists (caller, f). split; [reflexivity |].
  apply filter_In. split; [eapply rng_source_body_member; eauto |].
  simpl. eapply (proj1 (field_write_inventory_complete us_mario._particleFlags)); eauto.
Qed.

Definition rng_source_coverage_claim : Prop :=
  rng_source_catalogue_claim /\
  (forall version unit caller f target,
    In (caller, Gfun (Internal f)) (prog_defs (rng_source_program version unit)) ->
    call_occurs target (fn_body f) -> computed_call target = true ->
    In caller (expected_rng_computed_callers version unit)) /\
  (forall version unit caller f,
    In (caller, Gfun (Internal f)) (prog_defs (rng_source_program version unit)) ->
    field_write_occurs us_mario._particleFlags (fn_body f) ->
    In caller (expected_rng_particle_field_writers version unit)).

Theorem checked_rng_source_coverage_us_jp : rng_source_coverage_claim.
Proof. exact (conj checked_rng_source_catalogue_us_jp
  (conj generated_computed_call_site_coverage_us_jp
        generated_particle_field_write_coverage_us_jp)). Qed.
