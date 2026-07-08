(* spine-root: the NON-VACUITY certificate of the twelve-TU capstone --
   linked12_inhabited proves the twelve generated TUs actually CompCert-link,
   so noA_no_spawn_never_flying_linked12 quantifies over a NONEMPTY class. *)
(* ====================================================================== *)
(* LINKED12 SATISFIABILITY (P3 slice 3).                                   *)
(*                                                                        *)
(* The twelve-TU capstone assumes `linked12 lp` -- this file proves that   *)
(* assumption is satisfiable: `exists lp, linked12 lp`.  Structure:        *)
(*                                                                        *)
(*  - link_def_either: a linked globdef IS one of its two sides (the      *)
(*    varinit/vardef/fundef merge always returns an input).                *)
(*  - pair_ok: a DECIDABLE pairwise compatibility check (main equality,   *)
(*    the public gate + per-shared-id def link over the defmaps, and       *)
(*    composite-list compatibility), computed over defmap VIEWS.           *)
(*  - pair_ok_link: pair_ok => the Clight link succeeds, with the linked   *)
(*    program's main/public/types/defmap characterized.                    *)
(*  - pair_ok_stable: compatibility-with-r survives linking (via           *)
(*    link_def_either + the public append + the composite In-split).       *)
(*  - link_chain_of_ok: pairwise compatibility makes the whole left fold   *)
(*    succeed (induction with stability).                                  *)
(*  - twelve_pairwise: ONE vm_compute certificate over the whole 66-pair  *)
(*    product (calibrated: seconds; vm GC keeps peak at one pair's views). *)
(*                                                                        *)
(* The certificate only holds because the PIPELINE makes the TUs           *)
(* link-compatible: stringlit disambiguation + anonymous-composite         *)
(* canonicalization + the gMarioStates extern-array completion             *)
(* (pipeline/clightgen.sh, pipeline/canonicalize_anon.py) -- each found    *)
(* by running exactly this certificate and reading the counterexample.     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Maps AST Ctypes Clight Linking.
From SM64.Generated Require mario mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update mario_step.
From SM64.Proofs Require Import LinkedTwelve.
Import ListNotations.

Local Transparent Ctypes.Linker_fundef Linker_prog Linker_def
  Linker_vardef Linker_varinit Linker_types Linker_program.

(* ---------------------------------------------------------------------- *)
(* A linked def IS one of its two sides.                                   *)
(* ---------------------------------------------------------------------- *)

Lemma link_varinit_either : forall i1 i2 i,
    link_varinit i1 i2 = Some i -> i = i1 \/ i = i2.
Proof.
  unfold link_varinit; intros i1 i2 i H.
  destruct (classify_init i1) eqn:C1; destruct (classify_init i2) eqn:C2;
    try discriminate;
    try (injection H as <-; auto);
    try (match type of H with
         | context [zeq ?a ?b] =>
             destruct (zeq a b); [ injection H as <-; auto | discriminate ]
         end).
Qed.

Lemma link_vardef_either : forall (v1 v2 v : globvar type),
    link_vardef v1 v2 = Some v -> v = v1 \/ v = v2.
Proof.
  unfold link_vardef; intros v1 v2 v H.
  destruct (link (gvar_info v1) (gvar_info v2)) as [info |] eqn:Hi;
    [ | discriminate ].
  cbn in Hi.
  destruct (type_eq (gvar_info v1) (gvar_info v2)) as [Einfo |];
    [ | discriminate ].
  injection Hi as <-.
  destruct (link (gvar_init v1) (gvar_init v2)) as [init |] eqn:Hini;
    [ | discriminate ].
  cbn in Hini.
  destruct (eqb (gvar_readonly v1) (gvar_readonly v2)) eqn:Hro;
    [ | discriminate ].
  destruct (eqb (gvar_volatile v1) (gvar_volatile v2)) eqn:Hvo;
    [ | discriminate ].
  cbn in H. injection H as <-.
  apply eqb_prop in Hro. apply eqb_prop in Hvo.
  destruct (link_varinit_either _ _ _ Hini) as [-> | ->].
  - left. destruct v1; reflexivity.
  - right. rewrite Einfo, Hro, Hvo. destruct v2; reflexivity.
Qed.

Lemma link_def_either :
  forall (gd1 gd2 gd : globdef Clight.fundef type),
    link gd1 gd2 = Some gd -> gd = gd1 \/ gd = gd2.
Proof.
  intros gd1 gd2 gd H.
  destruct gd1 as [fd1 | v1]; destruct gd2 as [fd2 | v2]; cbn in H;
    try discriminate.
  - destruct (Ctypes.link_fundef fd1 fd2) eqn:Hf; [ | discriminate ].
    injection H as <-.
    destruct (Ctypes.link_fundef_either _ _ _ _ Hf) as [-> | ->]; auto.
  - destruct (link_vardef v1 v2) eqn:Hv; [ | discriminate ].
    injection H as <-.
    destruct (link_vardef_either _ _ _ Hv) as [-> | ->]; auto.
Qed.

Lemma link_def_compat :
  forall (gd1 gd2 gd12 gd3 : globdef Clight.fundef type),
    link gd1 gd2 = Some gd12 ->
    link gd1 gd3 <> None -> link gd2 gd3 <> None ->
    link gd12 gd3 <> None.
Proof.
  intros gd1 gd2 gd12 gd3 H H1 H2.
  destruct (link_def_either _ _ _ H) as [-> | ->]; assumption.
Qed.

(* ---------------------------------------------------------------------- *)
(* The decidable pairwise compatibility check, over defmap VIEWS so the    *)
(* final vm certificate forces each TU defmap exactly once.                *)
(* ---------------------------------------------------------------------- *)

Definition is_some {A} (o : option A) : bool :=
  match o with Some _ => true | None => false end.

Definition memb (i : ident) (l : list ident) : bool := existsb (Pos.eqb i) l.

Lemma memb_In : forall i l, memb i l = true -> In i l.
Proof.
  intros i l H. unfold memb in H.
  apply existsb_exists in H. destruct H as (j & Hin & Heq).
  apply Pos.eqb_eq in Heq. subst j. exact Hin.
Qed.

Lemma memb_app_l : forall i l l', memb i l = true -> memb i (l ++ l') = true.
Proof.
  intros i l l' H. unfold memb in *.
  apply existsb_exists. apply existsb_exists in H.
  destruct H as (x & Hin & Hx). exists x.
  split; [ apply in_or_app; auto | exact Hx ].
Qed.

Lemma memb_app_r : forall i l l', memb i l' = true -> memb i (l ++ l') = true.
Proof.
  intros i l l' H. unfold memb in *.
  apply existsb_exists. apply existsb_exists in H.
  destruct H as (x & Hin & Hx). exists x.
  split; [ apply in_or_app; auto | exact Hx ].
Qed.

Record tuv := mktuv {
  v_dm    : PTree.t (globdef Clight.fundef type);
  v_pub   : list ident;
  v_types : list composite_definition;
  v_main  : ident
}.

Definition view (p : Clight.program) : tuv :=
  mktuv (prog_defmap p) (prog_public p) (prog_types p) (prog_main p).

Definition pair_defs_ok (dm1 dm2 : PTree.t (globdef Clight.fundef type))
                        (pub1 pub2 : list ident) : bool :=
  PTree_Properties.for_all dm1
    (fun id gd1 =>
       match dm2 ! id with
       | None => true
       | Some gd2 => memb id pub1 && memb id pub2 && is_some (link gd1 gd2)
       end).

Definition pair_okv (a b : tuv) : bool :=
  Pos.eqb (v_main a) (v_main b)
  && pair_defs_ok (v_dm a) (v_dm b) (v_pub a) (v_pub b)
  && is_some (link_composite_defs (v_types a) (v_types b)).

Definition pair_ok (p q : Clight.program) : bool := pair_okv (view p) (view q).

(* the three components, extracted *)
Lemma pair_ok_parts : forall p q,
    pair_ok p q = true ->
    prog_main p = prog_main q
    /\ (forall id gd1 gd2,
           (prog_defmap p) ! id = Some gd1 ->
           (prog_defmap q) ! id = Some gd2 ->
           memb id (prog_public p) = true
           /\ memb id (prog_public q) = true
           /\ link gd1 gd2 <> None)
    /\ exists tys, link_composite_defs (prog_types p) (prog_types q) = Some tys.
Proof.
  intros p q H. unfold pair_ok, pair_okv, view in H;
    cbn [v_dm v_pub v_types v_main] in H.
  apply andb_prop in H as [H Hcomp].
  apply andb_prop in H as [Hmain Hdefs].
  split; [ | split ].
  - apply Pos.eqb_eq. exact Hmain.
  - intros id gd1 gd2 H1 H2.
    pose proof (proj1 (PTree_Properties.for_all_correct _ _) Hdefs id gd1 H1)
      as Hrow.
    cbv beta in Hrow.
    (* the scrutinee in Hrow is a delta-variant of H2's LHS (Clight.fundef
       vs its unfolding); bridge by conversion, then rewrite *)
    match type of Hrow with
    | context [match ?LK with _ => _ end] =>
        let E := fresh "E" in
        assert (E : LK = Some gd2) by exact H2;
        rewrite E in Hrow
    end.
    apply andb_prop in Hrow as [Hrow Hlnk].
    apply andb_prop in Hrow as [Hp1 Hp2].
    split; [ exact Hp1 | split; [ exact Hp2 | ] ].
    intros Hnone.
    match type of Hlnk with
    | is_some ?LK = true =>
        let E2 := fresh "E2" in
        assert (E2 : LK = None) by exact Hnone;
        rewrite E2 in Hlnk; cbn in Hlnk; discriminate Hlnk
    end.
  - destruct (link_composite_defs (prog_types p) (prog_types q)) eqn:HT;
      [ eauto | discriminate Hcomp ].
Qed.

(* ---------------------------------------------------------------------- *)
(* pair_ok implies the Clight-level link succeeds, with the linked         *)
(* program's fields characterized.                                         *)
(* ---------------------------------------------------------------------- *)

Lemma pair_ok_link : forall p q,
    pair_ok p q = true ->
    exists pq,
      link p q = Some pq
      /\ prog_main pq = prog_main p
      /\ prog_public pq = prog_public p ++ prog_public q
      /\ link_composite_defs (prog_types p) (prog_types q) = Some (prog_types pq)
      /\ (forall id, (prog_defmap pq) ! id
            = link_prog_merge ((prog_defmap p) ! id) ((prog_defmap q) ! id)).
Proof.
  intros p q H.
  destruct (pair_ok_parts _ _ H) as (Hmain & Hdefs & tys & HT).
  (* AST-level link_prog succeeds *)
  assert (HLP : link_prog (program_of_program p) (program_of_program q)
                = Some {| AST.prog_main := prog_main p;
                          AST.prog_public := prog_public p ++ prog_public q;
                          AST.prog_defs :=
                            PTree.elements
                              (PTree.combine link_prog_merge
                                 (prog_defmap p) (prog_defmap q)) |}).
  { apply link_prog_succeeds.
    - exact Hmain.
    - intros id gd1 gd2 H1 H2.
      destruct (Hdefs id gd1 gd2 H1 H2) as (Hp1 & Hp2 & Hl).
      split; [ | split ].
      + apply memb_In. exact Hp1.
      + apply memb_In. exact Hp2.
      + exact Hl. }
  (* Clight-level link_program *)
  unfold link at 1. unfold Linker_program, link_program.
  match goal with
  | |- context [match ?LKP with _ => _ end] =>
      replace LKP with (link_prog (program_of_program p) (program_of_program q))
        by reflexivity
  end.
  rewrite HLP.
  change (link (prog_types p) (prog_types q))
    with (link_composite_defs (prog_types p) (prog_types q)).
  destruct (lift_option (link_composite_defs (prog_types p) (prog_types q)))
    as [[tys' EQt] | EQn]; [ | exfalso; congruence ].
  assert (Etys : tys' = tys) by congruence. subst tys'.
  destruct (link_build_composite_env (prog_types p) (prog_types q) tys
              (prog_comp_env p) (prog_comp_env q)
              (prog_comp_env_eq p) (prog_comp_env_eq q) EQt)
    as [env [P Q]].
  eexists. split; [ reflexivity | ].
  cbn [Ctypes.prog_main Ctypes.prog_public Ctypes.prog_types].
  split; [ reflexivity | ]. split; [ reflexivity | ].
  split; [ exact HT | ].
  intros id.
  match goal with
  | |- (prog_defmap ?PQ) ! id = _ =>
      assert (Hconv : (prog_defmap PQ) ! id
                      = (prog_defmap
                           {| AST.prog_main := prog_main p;
                              AST.prog_public := prog_public p ++ prog_public q;
                              AST.prog_defs :=
                                PTree.elements
                                  (PTree.combine link_prog_merge
                                     (prog_defmap p) (prog_defmap q)) |}) ! id)
        by reflexivity
  end.
  rewrite Hconv, prog_defmap_elements, PTree.gcombine by reflexivity.
  reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* STABILITY: pairwise compatibility is preserved by linking.              *)
(* ---------------------------------------------------------------------- *)

Lemma pair_ok_stable : forall p q pq r,
    pair_ok p q = true -> link p q = Some pq ->
    pair_ok p r = true -> pair_ok q r = true ->
    pair_ok pq r = true.
Proof.
  intros p q pq r Hpq Hlink Hpr Hqr.
  destruct (pair_ok_link _ _ Hpq) as (pq' & Hlink' & Hmain & Hpub & HT & Hdm).
  assert (pq' = pq) by congruence. subst pq'. clear Hlink'.
  destruct (pair_ok_parts _ _ Hpr) as (Hmain_pr & Hdefs_pr & tys_pr & HT_pr).
  destruct (pair_ok_parts _ _ Hqr) as (Hmain_qr & Hdefs_qr & tys_qr & HT_qr).
  destruct (pair_ok_parts _ _ Hpq) as (Hmain_pq & _ & tys_pq & HT_pq).
  unfold pair_ok, pair_okv, view; cbn [v_dm v_pub v_types v_main].
  apply andb_true_intro; split; [ apply andb_true_intro; split | ].
  - (* main *)
    apply Pos.eqb_eq. rewrite Hmain. exact Hmain_pr.
  - (* defs.  NOTE: the goal's row terms are pair_defs_ok's delta-variants
       of the statement-level forms (Clight.fundef folded vs unfolded);
       every step first REPLACEs the goal term with the canonical form by
       conversion. *)
    apply (proj2 (PTree_Properties.for_all_correct _ _)).
    intros id gd12 H12. cbv beta.
    match goal with
    | |- match ?LK with _ => _ end = true =>
        replace LK with ((prog_defmap r) ! id) by reflexivity
    end.
    destruct ((prog_defmap r) ! id) as [gd3 |] eqn:H3; [ | reflexivity ].
    match type of H12 with
    | ?LK = _ =>
        replace LK with ((prog_defmap pq) ! id) in H12 by reflexivity
    end.
    rewrite Hdm in H12. unfold link_prog_merge in H12.
    destruct ((prog_defmap p) ! id) as [gd1 |] eqn:H1;
      destruct ((prog_defmap q) ! id) as [gd2 |] eqn:H2;
      cbn in H12; [ | | | discriminate H12 ].
    + (* both sides defined: gd12 = link gd1 gd2, use either + the pair rows *)
      destruct (Hdefs_pr id gd1 gd3 H1 H3) as (Hpub1 & Hpub3 & Hl13).
      destruct (Hdefs_qr id gd2 gd3 H2 H3) as (Hpub2 & _ & Hl23).
      apply andb_true_intro; split; [ apply andb_true_intro; split | ].
      * match goal with
        | |- memb id ?PU = true =>
            replace PU with (prog_public pq) by reflexivity
        end.
        rewrite Hpub. apply memb_app_l. exact Hpub1.
      * match goal with
        | |- memb id ?PU = true =>
            replace PU with (prog_public r) by reflexivity
        end.
        exact Hpub3.
      * match goal with
        | |- is_some ?LNK = true =>
            let E := fresh "ELNK" in
            assert (E : LNK <> None)
              by (destruct (link_def_either _ _ _ H12) as [-> | ->];
                  [ exact Hl13 | exact Hl23 ]);
            destruct LNK; [ reflexivity | congruence ]
        end.
    + (* p-only *)
      injection H12 as <-.
      destruct (Hdefs_pr id gd1 gd3 H1 H3) as (Hpub1 & Hpub3 & Hl13).
      apply andb_true_intro; split; [ apply andb_true_intro; split | ].
      * match goal with
        | |- memb id ?PU = true =>
            replace PU with (prog_public pq) by reflexivity
        end.
        rewrite Hpub. apply memb_app_l. exact Hpub1.
      * match goal with
        | |- memb id ?PU = true =>
            replace PU with (prog_public r) by reflexivity
        end.
        exact Hpub3.
      * match goal with
        | |- is_some ?LNK = true =>
            let E := fresh "ELNK" in
            assert (E : LNK <> None) by exact Hl13;
            destruct LNK; [ reflexivity | congruence ]
        end.
    + (* q-only *)
      injection H12 as <-.
      destruct (Hdefs_qr id gd2 gd3 H2 H3) as (Hpub2 & Hpub3 & Hl23).
      apply andb_true_intro; split; [ apply andb_true_intro; split | ].
      * match goal with
        | |- memb id ?PU = true =>
            replace PU with (prog_public pq) by reflexivity
        end.
        rewrite Hpub. apply memb_app_r. exact Hpub2.
      * match goal with
        | |- memb id ?PU = true =>
            replace PU with (prog_public r) by reflexivity
        end.
        exact Hpub3.
      * match goal with
        | |- is_some ?LNK = true =>
            let E := fresh "ELNK" in
            assert (E : LNK <> None) by exact Hl23;
            destruct LNK; [ reflexivity | congruence ]
        end.
  - (* composites: every cd in types_pq comes from types_p or types_q,
       and both are pairwise-compatible with types_r *)
    destruct (link_composite_def_inv _ _ _ HT_pq) as (_ & Etys & Hin_iff).
    assert (HTpq : link_composite_defs (prog_types p) (prog_types q)
                   = Some (prog_types pq)) by exact HT.
    assert (Epqtypes : prog_types pq
                       = prog_types p ++ filter_redefs (prog_types p) (prog_types q))
      by congruence.
    unfold link_composite_defs.
    destruct (forallb (check_compat_composite (prog_types r)) (prog_types pq))
      eqn:HF; [ reflexivity | ].
    exfalso.
    assert (HFtrue : forallb (check_compat_composite (prog_types r))
                       (prog_types pq) = true).
    { apply forallb_forall. intros cd Hcd.
      rewrite Epqtypes in Hcd.
      assert (Hcd' : In cd (prog_types p) \/ In cd (prog_types q)).
      { rewrite Etys in Hin_iff. apply Hin_iff. exact Hcd. }
      destruct Hcd' as [Hcp | Hcq].
      - unfold link_composite_defs in HT_pr.
        destruct (forallb (check_compat_composite (prog_types r))
                    (prog_types p)) eqn:Fp; [ | discriminate ].
        exact (proj1 (forallb_forall _ _) Fp cd Hcp).
      - unfold link_composite_defs in HT_qr.
        destruct (forallb (check_compat_composite (prog_types r))
                    (prog_types q)) eqn:Fq; [ | discriminate ].
        exact (proj1 (forallb_forall _ _) Fq cd Hcq). }
    congruence.
Qed.

(* ---------------------------------------------------------------------- *)
(* The chain: pairwise compatibility makes the whole left fold succeed.    *)
(* ---------------------------------------------------------------------- *)

Fixpoint pairwise_ok (l : list Clight.program) : bool :=
  match l with
  | nil => true
  | p :: l' => forallb (pair_ok p) l' && pairwise_ok l'
  end.

Lemma link_chain_of_ok :
  forall l p,
    forallb (pair_ok p) l = true ->
    pairwise_ok l = true ->
    exists lp, link_chain p l = Some lp.
Proof.
  induction l as [| q l IH]; intros p Hp Hl.
  - eexists; reflexivity.
  - cbn in Hp. apply andb_prop in Hp as [Hpq Hp'].
    cbn in Hl. apply andb_prop in Hl as [Hq Hl'].
    destruct (pair_ok_link _ _ Hpq) as (pq & Hlink & _).
    cbn [link_chain].
    match goal with
    | |- exists _, match ?LK with _ => _ end = _ =>
        replace LK with (link p q) by reflexivity
    end.
    rewrite Hlink.
    apply IH; [ | exact Hl' ].
    apply forallb_forall. intros r Hr.
    apply (pair_ok_stable p q pq r Hpq Hlink).
    + exact (proj1 (forallb_forall _ _) Hp' r Hr).
    + exact (proj1 (forallb_forall _ _) Hq r Hr).
Qed.


(* ---------------------------------------------------------------------- *)
(* THE CERTIFICATE: one vm_compute over the whole pairwise product.        *)
(* Calibrated 2026-07-09: a single pair check costs 0.04-0.19s in vm       *)
(* (vm GC's each pair's intermediates; peak memory = one pair's views),    *)
(* so the full 66-pair product is seconds.  Do NOT restructure this into   *)
(* per-pair lemmas assembled by cbn/rewrite: tactic-level manipulation of  *)
(* goals mentioning the TU constants is the known hang class.              *)
(* ---------------------------------------------------------------------- *)

Definition twelve : list Clight.program := mario.prog :: tu_rest.

(* stated as the two components link_chain_of_ok consumes, so the payoff
   below is a syntactic `exact` -- NO tactic-level conversion ever touches
   a goal mentioning the TU constants (the known hang class: a `change`
   here cost 4 CPU-hours before -time localized it) *)
Lemma twelve_head : forallb (pair_ok mario.prog) tu_rest = true.
Proof. vm_compute. reflexivity. Qed.

Lemma twelve_tail : pairwise_ok tu_rest = true.
Proof. vm_compute. reflexivity. Qed.



(* ---------------------------------------------------------------------- *)
(* THE PAYOFF                                                              *)
(* ---------------------------------------------------------------------- *)

Theorem linked12_inhabited : exists lp, linked12 lp.
Proof.
  unfold linked12.
  exact (link_chain_of_ok tu_rest mario.prog twelve_head twelve_tail).
Qed.
