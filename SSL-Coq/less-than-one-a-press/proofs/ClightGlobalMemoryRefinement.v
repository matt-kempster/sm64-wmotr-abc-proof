(** Concrete global-interface and initialized-memory refinement for the
    source-owned cleaned Clight links.

    This file never identifies blocks merely because two source names are
    equal.  It first proves exact definition/public-name agreement and then
    uses CompCert's initialized-memory machinery, including [Init_addrof]
    relocation stores. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking Maps
  Memory Values.
From LessThanOneAPress.Proofs Require Import LinkedClightPrograms
  NormalizedClightPrograms CleanedClightPrograms ClightLinkExecution.

Import ListNotations.

(** * The normalization map is a left-biased maximum-strength scan *)

Definition prefer_global_definition
    (incumbent candidate : option (globdef Clight.fundef type)) :=
  match incumbent, candidate with
  | None, result | result, None => result
  | Some old, Some new =>
      if Nat.ltb (global_definition_strength old)
                 (global_definition_strength new)
      then Some new else Some old
  end.

Fixpoint scan_global_definition
    (query : ident) (incumbent : option (globdef Clight.fundef type))
    (definitions : list (ident * globdef Clight.fundef type)) :=
  match definitions with
  | [] => incumbent
  | (id, candidate) :: rest =>
      scan_global_definition query
        (if peq query id
         then prefer_global_definition incumbent (Some candidate)
         else incumbent)
        rest
  end.

Lemma prefer_global_definition_assoc :
  forall left middle right,
    prefer_global_definition
      (prefer_global_definition left middle) right =
    prefer_global_definition left
      (prefer_global_definition middle right).
Proof.
  intros [left |] [middle |] [right |];
    try (unfold prefer_global_definition; reflexivity).
  unfold prefer_global_definition.
  destruct (Nat.ltb (global_definition_strength left)
    (global_definition_strength middle)) eqn:Hleft_middle;
  destruct (Nat.ltb (global_definition_strength middle)
    (global_definition_strength right)) eqn:Hmiddle_right.
  - assert (Hleft_right :
      Nat.ltb (global_definition_strength left)
        (global_definition_strength right) = true).
    { apply Nat.ltb_lt. apply Nat.ltb_lt in Hleft_middle.
      apply Nat.ltb_lt in Hmiddle_right. lia. }
    now rewrite Hleft_right.
  - now rewrite Hleft_middle.
  - reflexivity.
  - assert (Hleft_right :
      Nat.ltb (global_definition_strength left)
        (global_definition_strength right) = false).
    { apply Nat.ltb_ge. apply Nat.ltb_ge in Hleft_middle.
      apply Nat.ltb_ge in Hmiddle_right. lia. }
    now rewrite Hleft_middle, Hleft_right.
  - unfold prefer_global_definition.
    destruct (Nat.ltb (global_definition_strength left)
      (global_definition_strength middle)); reflexivity.
Qed.

Lemma scan_global_definition_factor :
  forall query definitions incumbent,
    scan_global_definition query incumbent definitions =
    prefer_global_definition incumbent
      (scan_global_definition query None definitions).
Proof.
  intros query definitions. induction definitions as
    [| [id candidate] rest IH]; intros incumbent; cbn.
  - destruct incumbent; reflexivity.
  - destruct (peq query id).
    + rewrite (IH (prefer_global_definition incumbent (Some candidate))).
      rewrite (IH (Some candidate)).
      apply prefer_global_definition_assoc.
    + apply IH.
Qed.

Lemma insert_preferred_global_definition_map_get :
  forall definitions query id candidate,
    PTree.get query
      (insert_preferred_global_definition_map definitions (id, candidate)) =
    if peq query id
    then prefer_global_definition (PTree.get query definitions)
           (Some candidate)
    else PTree.get query definitions.
Proof.
  intros definitions query id candidate.
  destruct (peq query id) as [Hequal | Hdifferent].
  - subst query. unfold insert_preferred_global_definition_map.
    destruct (PTree.get id definitions) as [incumbent |] eqn:Hget.
    + unfold prefer_global_definition.
      destruct (Nat.ltb (global_definition_strength incumbent)
        (global_definition_strength candidate)) eqn:Hstronger.
      * apply PTree.gss.
      * exact Hget.
    + apply PTree.gss.
  - unfold insert_preferred_global_definition_map.
    destruct (PTree.get id definitions) as [incumbent |] eqn:Hget;
      [destruct (Nat.ltb (global_definition_strength incumbent)
                         (global_definition_strength candidate)) |];
      cbn; try rewrite PTree.gso by exact Hdifferent; reflexivity.
Qed.

Lemma fold_preferred_global_definition_map_get :
  forall definitions initial query,
    PTree.get query
      (fold_left insert_preferred_global_definition_map definitions initial) =
    scan_global_definition query (PTree.get query initial) definitions.
Proof.
  intros definitions. induction definitions as
    [| [id candidate] rest IH]; intros initial query.
  - reflexivity.
  - cbn [fold_left scan_global_definition].
    rewrite IH, insert_preferred_global_definition_map_get.
    reflexivity.
Qed.

Theorem normalized_global_definition_map_get_scan :
  forall definitions query,
    PTree.get query (normalize_global_definition_map definitions) =
    scan_global_definition query None definitions.
Proof.
  intros definitions query.
  unfold normalize_global_definition_map.
  rewrite fold_preferred_global_definition_map_get, PTree.gempty.
  reflexivity.
Qed.

(** * Concrete strong-definition agreement *)

(** The already-checked source selector and official linker prove the exact
    payload agreement that is sound for strong definitions: every source
    internal body and every definitive initialized global selected by the
    normalization occurs verbatim in the concrete official result.  Weak
    declarations and tentative variables are intentionally excluded. *)

Theorem us_concrete_strong_definition_membership_agreement :
  incl (filter preserve_definition_verbatim
          (unit_global_definitions us_units))
       (Ctypes.prog_defs us_official_cleaned_slice).
Proof.
  exact us_official_preserves_source_strong_definitions_verbatim.
Qed.

Theorem jp_concrete_strong_definition_membership_agreement :
  incl (filter preserve_definition_verbatim
          (unit_global_definitions jp_units))
       (Ctypes.prog_defs jp_official_cleaned_slice).
Proof.
  exact jp_official_preserves_source_strong_definitions_verbatim.
Qed.

(** * Ordered/public interface and initialized-memory boundary *)

Definition OrderedGlobalDefinitionAgreement
    (source target : Clight.program) : Prop :=
  Ctypes.prog_defs source = Ctypes.prog_defs target.

Definition GlobalDefinitionLookupAgreement
    (source target : Clight.program) : Prop :=
  forall id, (prog_defmap source) ! id = (prog_defmap target) ! id.

Definition ExactPublicNameAgreement
    (source target : Clight.program) : Prop :=
  forall id,
    In id (Ctypes.prog_public source) <->
    In id (Ctypes.prog_public target).

Lemma ordered_global_definitions_give_lookup_agreement :
  forall source target,
    OrderedGlobalDefinitionAgreement source target ->
    GlobalDefinitionLookupAgreement source target.
Proof.
  intros source target Hdefinitions id.
  unfold OrderedGlobalDefinitionAgreement in Hdefinitions.
  change (PTree.get id
      (PTree_Properties.of_list (Ctypes.prog_defs source)) =
    PTree.get id
      (PTree_Properties.of_list (Ctypes.prog_defs target))).
  now rewrite Hdefinitions.
Qed.

Definition RelocationAwareInitialMemoryInjection
    (source target : Clight.program) (injection : meminj) : Prop :=
  exists source_memory target_memory,
    Genv.init_mem source = Some source_memory /\
    Genv.init_mem target = Some target_memory /\
    Mem.inject injection source_memory target_memory.

(** [Genv.init_mem_match] executes allocation and all initializer stores,
    including [Init_addrof].  Therefore this theorem is stronger than a
    symbol-domain check: under an actual CompCert [match_program_gen] witness,
    both programs have the very same initialized memory and its relocation
    pointer contents are covered by [Mem.inject]. *)
Theorem matched_program_initial_memory_is_relocation_aware :
  forall source target
      (match_function :
        unit -> Clight.fundef -> Clight.fundef -> Prop)
      (match_variable : type -> type -> Prop),
    Linking.match_program_gen match_function match_variable tt
      (program_of_program source) (program_of_program target) ->
    forall memory,
      Genv.init_mem source = Some memory ->
      RelocationAwareInitialMemoryInjection source target
        (Mem.flat_inj (Mem.nextblock memory)).
Proof.
  intros source target match_function match_variable Hprogram memory Hinitial.
  pose proof (Genv.init_mem_match Hprogram Hinitial) as Htarget.
  exists memory, memory. split; [exact Hinitial |].
  split; [exact Htarget |].
  exact (Genv.initmem_inject (program_of_program source) Hinitial).
Qed.

(** A current-memory injection transports any initialized relocation load, as
    well as later loads of the same pointer, through the concrete block map.
    The statement uses finite-width CompCert values and byte offsets. *)
Theorem memory_injection_transports_loaded_relocation :
  forall injection source_memory target_memory chunk
      source_block target_block delta offset value,
    Mem.inject injection source_memory target_memory ->
    injection source_block = Some (target_block, delta) ->
    Mem.load chunk source_memory source_block offset = Some value ->
    exists target_value,
      Mem.load chunk target_memory target_block (offset + delta) =
        Some target_value /\
      Val.inject injection value target_value.
Proof.
  intros injection source_memory target_memory chunk source_block target_block
    delta offset value Hmemory Hblock Hload.
  eapply Mem.load_inject; eauto.
Qed.

Record NormalizedOfficialGlobalMemoryRefinement
    (normalized official : Clight.program) : Prop := {
  normalized_official_definition_lookup :
    GlobalDefinitionLookupAgreement normalized official;
  normalized_official_public_names :
    ExactPublicNameAgreement normalized official;
  normalized_official_initial_memory :
    OfficialLinkInitialMemoryInjection normalized official
}.

(** These are the exact remaining concrete global-memory targets.  They are
    transparent propositions over the actual linked US/JP programs, not
    parameters and not claims that the targets have already been proved. *)
Definition USNormalizedOfficialGlobalMemoryRefinementObligation : Prop :=
  NormalizedOfficialGlobalMemoryRefinement
    us_normalized_semantic_slice us_official_cleaned_slice.

Definition JPNormalizedOfficialGlobalMemoryRefinementObligation : Prop :=
  NormalizedOfficialGlobalMemoryRefinement
    jp_normalized_semantic_slice jp_official_cleaned_slice.
