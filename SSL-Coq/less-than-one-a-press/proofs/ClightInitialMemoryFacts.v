(** Lightweight generic facts for constructing CompCert initial memories. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs.

Import ListNotations.
Local Open Scope Z_scope.

Definition init_data_alignment_ok (offset : Z) (datum : init_data) : bool :=
  Z.eqb (Z.modulo offset (Genv.init_data_alignment datum)) 0.

Fixpoint init_data_list_alignment_ok
    (offset : Z) (data : list init_data) : bool :=
  match data with
  | [] => true
  | datum :: rest =>
      init_data_alignment_ok offset datum &&
      init_data_list_alignment_ok (offset + init_data_size datum) rest
  end.

Definition global_initializer_alignment_ok
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gvar variable => init_data_list_alignment_ok 0 (gvar_init variable)
  | _ => true
  end.

Definition program_initializers_alignment_ok
    (program : Clight.program) : bool :=
  forallb global_initializer_alignment_ok (prog_defs program).

Definition ProgramInitializersAligned (program : Clight.program) : Prop :=
  forall id variable,
    In (id, Gvar variable) (prog_defs program) ->
    Genv.init_data_list_aligned 0 (gvar_init variable).

Fixpoint NListProgramInitializersAligned
    (programs : nlist Clight.program) : Prop :=
  match programs with
  | nbase program => ProgramInitializersAligned program
  | ncons program rest =>
      ProgramInitializersAligned program /\
      NListProgramInitializersAligned rest
  end.

Fixpoint nlist_program_definitions
    (programs : nlist Clight.program) :
    list (ident * globdef Clight.fundef type) :=
  match programs with
  | nbase program => prog_defs program
  | ncons program rest =>
      prog_defs program ++ nlist_program_definitions rest
  end.

Lemma nlist_program_initializers_aligned_base :
  forall program,
    ProgramInitializersAligned program ->
    NListProgramInitializersAligned (nbase program).
Proof. intros program Haligned. exact Haligned. Qed.

Lemma nlist_program_initializers_aligned_cons :
  forall program rest,
    ProgramInitializersAligned program ->
    NListProgramInitializersAligned rest ->
    NListProgramInitializersAligned (ncons program rest).
Proof. intros program rest Hprogram Hrest. now split. Qed.

Lemma init_data_list_alignment_ok_sound :
  forall offset data,
    init_data_list_alignment_ok offset data = true ->
    Genv.init_data_list_aligned offset data.
Proof.
  intros offset data. revert offset.
  induction data as [| datum rest IH]; intros offset Hchecked; cbn in *.
  - exact I.
  - apply andb_true_iff in Hchecked. destruct Hchecked as [Hhead Hrest].
    split.
    + unfold init_data_alignment_ok in Hhead.
      apply Z.eqb_eq in Hhead.
      apply Z.mod_divide; [destruct datum; cbn; discriminate | exact Hhead].
    + exact (IH _ Hrest).
Qed.

Lemma program_initializers_alignment_ok_sound :
  forall program,
    program_initializers_alignment_ok program = true ->
    ProgramInitializersAligned program.
Proof.
  intros program Hchecked id variable Hin.
  unfold program_initializers_alignment_ok in Hchecked.
  rewrite forallb_forall in Hchecked.
  specialize (Hchecked (id, Gvar variable) Hin).
  cbn in Hchecked.
  exact (init_data_list_alignment_ok_sound 0 _ Hchecked).
Qed.

Lemma nlist_program_initializers_aligned_sound :
  forall programs,
    NListProgramInitializersAligned programs ->
    forall id variable,
      In (id, Gvar variable) (nlist_program_definitions programs) ->
      Genv.init_data_list_aligned 0 (gvar_init variable).
Proof.
  intros programs. induction programs as [program | program rest IH]; cbn.
  - intros Haligned id variable Hin. exact (Haligned id variable Hin).
  - intros [Hprogram Hrest] id variable Hin.
    apply in_app_or in Hin. destruct Hin as [Hin | Hin].
    + exact (Hprogram id variable Hin).
    + exact (IH Hrest id variable Hin).
Qed.
