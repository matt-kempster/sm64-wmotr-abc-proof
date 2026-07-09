(* spine-root: the INIT-MEM certificate of the twelve-TU capstone (P5 slice 6,
   task #92).  Proves `exists m, Genv.init_mem lp = Some m` for EVERY twelve-TU
   link -- the direct analogue of Linked12Sat.linked12_inhabited, discharging
   the last dischargeable bucket-B residual (the `exists init, init_mem lp =
   Some init` conjunct hiding inside the capstone's Hspawn premise). *)
(* ====================================================================== *)
(* INIT-MEM SATISFIABILITY (P5 slice 6).                                   *)
(*                                                                        *)
(* Genv.init_mem_exists reduces `exists m, init_mem lp = Some m` to a fact *)
(* about EVERY (id, Gvar v) in prog_defs lp: its init-data is aligned and  *)
(* every Init_addrof target resolves in lp's genv.  prog_defs lp is not    *)
(* computable (whole-program link OOMs), so -- exactly as pair_ok_stable / *)
(* link_chain_of_ok did for compatibility -- we reduce to PER-TU decidable *)
(* checks + a chain-preservation (origin) lemma:                          *)
(*                                                                        *)
(*  - clight_link_shape: a successful Clight link's prog_defs IS the       *)
(*    PTree.combine of the two defmaps under link_prog_merge (from         *)
(*    link_prog_inv); hence its defmap is that combine and its names are   *)
(*    norepet.                                                             *)
(*  - clight_link_globdef_origin / link_chain_gvar_origin: a gvar in lp    *)
(*    IS (identically -- via Linked12Sat.link_def_either) a gvar of ONE of *)
(*    the twelve TUs at the same id.                                       *)
(*  - tu_gvars_ok (decidable, per TU): every gvar's init-data is aligned   *)
(*    AND every Init_addrof target is defined in that SAME TU's defmap     *)
(*    (C requires the symbol declared to take its address).  ONE vm cert   *)
(*    over the twelve (twelve_gvars_ok).                                   *)
(*  - assembly: the gvar's origin TU q has linkorder q lp (LinkedTwelve),  *)
(*    so its self-defined addrof targets resolve in lp's genv              *)
(*    (SpawnInit.linkorder_resolves_symbol), and its aligned init-data is  *)
(*    aligned in lp.  init_mem_exists then delivers the memory.            *)
(*                                                                        *)
(* PERF LAW (Linked12Sat header): the vm cert is one closed lemma in       *)
(* consumer shape; the assembly connects by exact/apply and NEVER lets     *)
(* cbn/change/rewrite touch a goal mentioning a whole-TU constant.         *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool.
From Coq Require Import Znumtheory.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Clight Linking.
From SM64.Generated Require mario mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update mario_step.
From SM64.Proofs Require Import LinkedTwelve Linked12Sat SpawnInit.
Import ListNotations.

Local Transparent Ctypes.Linker_fundef Linker_prog Linker_def
  Linker_vardef Linker_varinit Linker_types Linker_program.

(* ---------------------------------------------------------------------- *)
(* Decidable per-gvar checks: alignment + addrof-self-defined.             *)
(* ---------------------------------------------------------------------- *)

Definition ida_aligned_b (p : Z) (i : init_data) : bool :=
  proj_sumbool (Zdivide_dec (Genv.init_data_alignment i) p).

Fixpoint idl_aligned_b (p : Z) (il : list init_data) : bool :=
  match il with
  | nil => true
  | i :: il' => ida_aligned_b p i && idl_aligned_b (p + init_data_size i) il'
  end.

Lemma idl_aligned_b_sound :
  forall il p, idl_aligned_b p il = true -> Genv.init_data_list_aligned p il.
Proof.
  induction il as [| i il' IH]; intros p H; cbn in H; cbn.
  - exact I.
  - apply andb_prop in H as [Hd Hrest]. split.
    + unfold ida_aligned_b in Hd.
      destruct (Zdivide_dec (Genv.init_data_alignment i) p) as [Hdiv | ]; [ exact Hdiv | discriminate ].
    + apply IH; exact Hrest.
Qed.

(* every Init_addrof target of the init-data list is defined in dm *)
Definition idl_addrof_defined_b (dm : PTree.t (globdef Clight.fundef type))
                                (il : list init_data) : bool :=
  forallb (fun d => match d with
                    | Init_addrof i _ => is_some (dm ! i)
                    | _ => true
                    end) il.

(* per-TU: every gvar's init-data is aligned AND self-addrof-defined *)
Definition tu_gvars_ok (p : Clight.program) : bool :=
  PTree_Properties.for_all (prog_defmap p)
    (fun _ gd => match gd with
                 | Gvar v => idl_aligned_b 0 v.(gvar_init)
                             && idl_addrof_defined_b (prog_defmap p) v.(gvar_init)
                 | _ => true
                 end).

(* ---------------------------------------------------------------------- *)
(* A successful Clight link's prog_defs is the PTree.combine of the two    *)
(* defmaps (from link_prog_inv); hence its defmap is that combine and its  *)
(* names are norepet.                                                      *)
(* ---------------------------------------------------------------------- *)

Lemma clight_link_shape :
  forall (p q pq : Clight.program), link p q = Some pq ->
    prog_defs pq =
      PTree.elements (PTree.combine link_prog_merge
                        (prog_defmap p) (prog_defmap q)).
Proof.
  intros p q pq H.
  unfold link, Linker_program, link_program in H.
  destruct (link (program_of_program p) (program_of_program q)) as [past |] eqn:LP;
    [ | discriminate ].
  destruct (lift_option (link (prog_types p) (prog_types q))) as [[typs EQ] | En];
    [ | discriminate ].
  destruct (link_build_composite_env (prog_types p) (prog_types q) typs
              (prog_comp_env p) (prog_comp_env q)
              (prog_comp_env_eq p) (prog_comp_env_eq q) EQ) as [env [P Q]].
  injection H as <-.
  cbn [prog_defs].
  change (link (program_of_program p) (program_of_program q))
    with (link_prog (program_of_program p) (program_of_program q)) in LP.
  apply link_prog_inv in LP. destruct LP as (_ & _ & ->).
  cbn [AST.prog_defs].
  reflexivity.
Qed.

Lemma clight_link_defmap :
  forall (p q pq : Clight.program) id, link p q = Some pq ->
    (prog_defmap pq) ! id
      = link_prog_merge ((prog_defmap p) ! id) ((prog_defmap q) ! id).
Proof.
  intros p q pq id H.
  unfold prog_defmap at 1.
  change (AST.prog_defs (program_of_program pq)) with (prog_defs pq).
  rewrite (clight_link_shape _ _ _ H).
  rewrite PTree_Properties.of_list_elements.
  rewrite PTree.gcombine by reflexivity.
  reflexivity.
Qed.

Lemma clight_link_norepet :
  forall (p q pq : Clight.program), link p q = Some pq ->
    list_norepet (prog_defs_names pq).
Proof.
  intros p q pq H. unfold prog_defs_names.
  change (AST.prog_defs (program_of_program pq)) with (prog_defs pq).
  rewrite (clight_link_shape _ _ _ H).
  apply PTree.elements_keys_norepet.
Qed.

(* ---------------------------------------------------------------------- *)
(* Origin: a def in a link IS one of its two sides (identically), and by   *)
(* chain-induction a def in lp is one of the twelve TUs' defs.             *)
(* ---------------------------------------------------------------------- *)

Lemma clight_link_globdef_origin :
  forall (p q pq : Clight.program) id gd,
    link p q = Some pq ->
    (prog_defmap pq) ! id = Some gd ->
    (prog_defmap p) ! id = Some gd \/ (prog_defmap q) ! id = Some gd.
Proof.
  intros p q pq id gd Hlink Hdm.
  rewrite (clight_link_defmap _ _ _ id Hlink) in Hdm.
  unfold link_prog_merge in Hdm.
  destruct ((prog_defmap p) ! id) as [g1 |] eqn:E1;
    destruct ((prog_defmap q) ! id) as [g2 |] eqn:E2.
  - destruct (link_def_either _ _ _ Hdm) as [-> | ->]; auto.
  - left. exact Hdm.
  - right. exact Hdm.
  - discriminate.
Qed.

Lemma link_chain_gvar_origin :
  forall l p lp id v,
    link_chain p l = Some lp ->
    (prog_defmap lp) ! id = Some (Gvar v) ->
    (prog_defmap p) ! id = Some (Gvar v)
    \/ exists q, In q l /\ (prog_defmap q) ! id = Some (Gvar v).
Proof.
  induction l as [| r l' IH]; intros p lp id v Hc Hdm; cbn [link_chain] in Hc.
  - injection Hc as <-. left. exact Hdm.
  - destruct (link p r) as [pr |] eqn:Hpr; [ | discriminate ].
    destruct (IH pr lp id v Hc Hdm) as [Hpr_dm | (q & Hin & Hq)].
    + destruct (clight_link_globdef_origin _ _ _ _ _ Hpr Hpr_dm) as [Hp | Hr].
      * left. exact Hp.
      * right. exists r. split; [ apply in_eq | exact Hr ].
    + right. exists q. split; [ apply in_cons; exact Hin | exact Hq ].
Qed.

(* lp (a nonempty-list link_chain result) has norepet names. *)
Lemma link_chain_norepet :
  forall l p lp, l <> nil -> link_chain p l = Some lp ->
    list_norepet (prog_defs_names lp).
Proof.
  induction l as [| r l' IH]; intros p lp Hne Hc; [ contradiction | ].
  cbn [link_chain] in Hc. destruct (link p r) as [pr |] eqn:Hpr; [ | discriminate ].
  destruct l' as [| s l''].
  - cbn [link_chain] in Hc. injection Hc as <-. exact (clight_link_norepet _ _ _ Hpr).
  - apply (IH pr lp); [ discriminate | exact Hc ].
Qed.

(* ---------------------------------------------------------------------- *)
(* THE PER-TU CERTIFICATE: one vm_compute over the twelve.                 *)
(* ---------------------------------------------------------------------- *)

Lemma twelve_gvars_ok : forallb tu_gvars_ok (mario.prog :: tu_rest) = true.
Proof. vm_compute. reflexivity. Qed.

(* per-TU extraction: the head (mario.prog) and every tail member pass. *)
Lemma mario_gvars_ok : tu_gvars_ok mario.prog = true.
Proof.
  pose proof twelve_gvars_ok as H. cbn [forallb] in H.
  apply andb_prop in H as [H _]. exact H.
Qed.

Lemma rest_gvars_ok : forall q, In q tu_rest -> tu_gvars_ok q = true.
Proof.
  pose proof twelve_gvars_ok as H. cbn [forallb] in H.
  apply andb_prop in H as [_ H].
  intros q Hin. exact (proj1 (forallb_forall _ _) H q Hin).
Qed.

(* a passing TU's gvar is aligned and self-addrof-defined (abstract dm inside
   the reflection lemmas -> no TU forced). *)
Lemma tu_gvars_ok_gvar :
  forall p id v, tu_gvars_ok p = true ->
    (prog_defmap p) ! id = Some (Gvar v) ->
    idl_aligned_b 0 v.(gvar_init) = true
    /\ idl_addrof_defined_b (prog_defmap p) v.(gvar_init) = true.
Proof.
  intros p id v Hok Hdm. unfold tu_gvars_ok in Hok.
  pose proof (proj1 (PTree_Properties.for_all_correct _ _) Hok id (Gvar v) Hdm)
    as Hrow.
  set (dm := prog_defmap p) in Hrow |- *.
  cbv beta iota in Hrow.
  apply andb_prop in Hrow. exact Hrow.
Qed.

(* reflection: addrof-defined bool (over an ABSTRACT dm) -> every addrof
   target is In dm. *)
Lemma idl_addrof_defined_b_sound :
  forall dm il, idl_addrof_defined_b dm il = true ->
    forall i o, In (Init_addrof i o) il -> is_some (dm ! i) = true.
Proof.
  unfold idl_addrof_defined_b.
  induction il as [| d il' IH]; intros Hb i o Hin.
  - inversion Hin.
  - cbn in Hb, Hin. apply andb_prop in Hb as [Hd Hrest].
    destruct Hin as [-> | Hin].
    + cbn in Hd. exact Hd.
    + exact (IH Hrest i o Hin).
Qed.

(* is_some -> exists, PROVED ABSTRACTLY: consumes is_some (dm ! i) = true
   without ever `destruct`ing / `cbn`ing the TU-defmap lookup (the PERF LAW:
   a `destruct ((prog_defmap mario.prog) ! i) eqn:` + `cbn` forces the whole
   TU and hangs -- this helper keeps the lookup an opaque atom). *)
Lemma is_some_exists :
  forall {A} (o : option A), is_some o = true -> exists a, o = Some a.
Proof. intros A [a |] H; [ exists a; reflexivity | discriminate ]. Qed.

(* ---------------------------------------------------------------------- *)
(* THE PAYOFF: init_mem exists for every twelve-TU link.                   *)
(* ---------------------------------------------------------------------- *)

Section Assemble.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.

  (* the init_mem_exists hypothesis, discharged per gvar via origin + the
     per-TU checks + linkorder symbol resolution. *)
  Lemma linked12_gvar_init_ok :
    forall id v, In (id, Gvar v) (prog_defs lp) ->
      Genv.init_data_list_aligned 0 v.(gvar_init)
      /\ forall i o, In (Init_addrof i o) v.(gvar_init) ->
                     exists b, Genv.find_symbol (globalenv lp) i = Some b.
  Proof.
    intros id v Hin.
    assert (Hnr : list_norepet (prog_defs_names lp)).
    { unfold linked12 in H12.
      apply (link_chain_norepet tu_rest mario.prog lp); [ discriminate | exact H12 ]. }
    assert (Hdm : (prog_defmap lp) ! id = Some (Gvar v))
      by (apply prog_defmap_norepet; assumption).
    unfold linked12 in H12.
    destruct (link_chain_gvar_origin tu_rest mario.prog lp id v H12 Hdm)
      as [Hmario | (q & Hinq & Hq)].
    - pose proof (tu_gvars_ok_gvar mario.prog id v mario_gvars_ok Hmario)
        as (Hal & Haddr).
      split; [ apply idl_aligned_b_sound; exact Hal | ].
      intros i o Hio.
      pose proof (idl_addrof_defined_b_sound _ _ Haddr i o Hio) as Hsome.
      destruct (is_some_exists _ Hsome) as (gd & E).
      exact (linkorder_resolves_symbol lp mario.prog i gd
               (link_chain_linkorder_base tu_rest mario.prog lp H12) E).
    - pose proof (rest_gvars_ok q Hinq) as Hokq.
      pose proof (tu_gvars_ok_gvar q id v Hokq Hq) as (Hal & Haddr).
      split; [ apply idl_aligned_b_sound; exact Hal | ].
      intros i o Hio.
      pose proof (idl_addrof_defined_b_sound _ _ Haddr i o Hio) as Hsome.
      destruct (is_some_exists _ Hsome) as (gd & E).
      exact (linkorder_resolves_symbol lp q i gd
               (link_chain_linkorder_in tu_rest mario.prog lp q Hinq H12) E).
  Qed.

  Theorem linked12_init_mem : exists m, Genv.init_mem lp = Some m.
  Proof.
    apply Genv.init_mem_exists.
    intros id v Hin. exact (linked12_gvar_init_ok id v Hin).
  Qed.
End Assemble.

(* ---------------------------------------------------------------------- *)
(* CONSUMPTION: spawn_ok is now satisfiable from linked12 ALONE (the        *)
(* init_mem residual of SpawnInit.spawn_ok_sat is discharged).             *)
(* ---------------------------------------------------------------------- *)

Theorem linked12_spawn_sat :
  forall lp, linked12 lp ->
    exists init bm bc oc0, spawn_ok lp init bm bc oc0.
Proof.
  intros lp H12.
  exact (spawn_ok_sat lp H12 (linked12_init_mem lp H12)).
Qed.
