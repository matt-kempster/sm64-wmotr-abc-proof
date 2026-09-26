(* kept: general tool -- a COMPUTABLE global environment for a Clight link chain,
   proved equal to [globalenv lp] for the real linked program.  Needed because
   CompCert's Clight [link] threads its composite env through a Qed lemma
   (Ctypes.link_build_composite_env), so vm_compute of a real link gets stuck
   and reading back the stuck term (the whole program) exhausts memory. *)

(* The trick: a linked program is determined by two computable pieces -- the
   AST-level link (defs/public/main) and the linked composite list -- and its
   composite env is the unique [env] with [build_composite_env types = OK env]. *)

From Coq Require Import List.
From compcert Require Import Coqlib Errors Maps AST Globalenvs Ctypes Clight Linking.
From SM64.Proofs Require Import LinkedTwelve.
Import ListNotations.

Local Transparent Linker_program.

(* The computable shadow of a Clight program. *)
Definition parts : Type :=
  (AST.program (Ctypes.fundef function) type * list composite_definition)%type.

Definition parts_of (p : Clight.program) : parts := (program_of_program p, prog_types p).

Lemma link_parts : forall p1 p2 p : Clight.program,
    link p1 p2 = Some p ->
    link (program_of_program p1) (program_of_program p2) = Some (program_of_program p) /\
    link (prog_types p1) (prog_types p2) = Some (prog_types p).
Proof.
  intros p1 p2 p H. cbn [link Linker_program] in H. unfold link_program in H.
  destruct (link (program_of_program p1) (program_of_program p2)) as [q|] eqn:Hq;
    [ | discriminate].
  destruct (lift_option (link (prog_types p1) (prog_types p2))) as [[typs EQ]|EQ];
    [ | discriminate].
  destruct (link_build_composite_env _ _ _ _ _ _ _ EQ) as [env [P Q]].
  inv H. split; [ destruct q; reflexivity | exact EQ ].
Qed.

Fixpoint parts_chain (x : parts) (l : list Clight.program) : option parts :=
  match l with
  | nil => Some x
  | q :: l' =>
      match link (fst x) (program_of_program q), link (snd x) (prog_types q) with
      | Some a, Some b => parts_chain (a, b) l'
      | _, _ => None
      end
  end.

Lemma parts_chain_ok : forall l (p lp : Clight.program),
    link_chain p l = Some lp -> parts_chain (parts_of p) l = Some (parts_of lp).
Proof.
  induction l as [|q l IH]; intros p lp H; cbn [link_chain parts_chain] in H |- *.
  - congruence.
  - destruct (link p q) as [pq|] eqn:Hpq; [ | discriminate].
    destruct (link_parts _ _ _ Hpq) as [H1 H2].
    change (parts_of p) with (program_of_program p, prog_types p); cbn [fst snd].
    rewrite H1, H2.
    exact (IH _ _ H).
Qed.

Definition genv_of_parts (x : parts) : option genv :=
  match build_composite_env (snd x) with
  | OK env => Some {| genv_genv := Genv.globalenv (fst x); genv_cenv := env |}
  | Error _ => None
  end.

Lemma genv_of_parts_ok : forall p : Clight.program,
    genv_of_parts (parts_of p) = Some (globalenv p).
Proof.
  intros p. unfold genv_of_parts, parts_of; cbn [fst snd].
  rewrite (prog_comp_env_eq p). reflexivity.
Qed.

(* THE BRIDGE: for any link chain, the computable genv IS the real one. *)
Theorem chain_genv : forall (p : Clight.program) l lp,
    link_chain p l = Some lp ->
    match parts_chain (parts_of p) l with
    | Some x => genv_of_parts x
    | None => None
    end = Some (globalenv lp).
Proof.
  intros p l lp H. rewrite (parts_chain_ok _ _ _ H). apply genv_of_parts_ok.
Qed.

(* Specialised to the twelve-TU link of the GOAL-1 capstone. *)
Definition ge12 : option genv :=
  match parts_chain (parts_of SM64.Generated.mario.prog) tu_rest with
  | Some x => genv_of_parts x
  | None => None
  end.

Theorem ge12_ok : forall lp, linked12 lp -> ge12 = Some (globalenv lp).
Proof. intros lp H. exact (chain_genv _ _ _ H). Qed.

(* The linked AST program itself (for building memories / init_mem). *)
Definition ast12 : option (AST.program fundef type) :=
  match parts_chain (parts_of SM64.Generated.mario.prog) tu_rest with
  | Some x => Some (fst x)
  | None => None
  end.

Theorem ast12_ok : forall lp, linked12 lp -> ast12 = Some (program_of_program lp).
Proof.
  intros lp H. unfold ast12. rewrite (parts_chain_ok _ _ _ H). reflexivity.
Qed.
