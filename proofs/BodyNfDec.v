(* BodyNfDec.v -- a DECIDABLE frame check, and its soundness.
 *
 * body_nf_ok (ValueFrameStmt) is the per-statement obligation the frame consumes;
 * proving it per function is currently a hand-written `all: try solve [...]`
 * dispatcher. This file replaces that with a COMPUTABLE predicate body_nf_ok_dec
 * and proves body_nf_ok_dec PT FS s = true -> body_nf_ok PT FS bm e s. So a
 * function's frame obligation becomes a `vm_compute; reflexivity` -- the syntactic
 * skeleton of the static rootedness analysis (PT/FS are still supplied per fn; an
 * automatic dataflow deriving them, plus the locally_safe connection, is the next
 * step). Scope: straight-line + branches + loops + calls; Sswitch is rejected for
 * now (switch fns keep their dispatcher), keeping soundness a single induction.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import List Bool.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionFrame ActionValueFrame MarioMemWF
  ResetBodystate RootedLvalue ValueFrameINV ValueFrameStmt.

(* root temp of a (possibly nested) chase lvalue. *)
Fixpoint expr_root (a : expr) : option ident :=
  match a with
  | Etempvar q _       => Some q
  | Efield a' _ _      => expr_root a'
  | Ederef a' _        => expr_root a'
  | Ebinop Oadd a' _ _ => expr_root a'
  | _                  => None
  end.

Definition lv_root (a : expr) : option ident :=
  match a with
  | Ederef a' _   => expr_root a'
  | Efield a' _ _ => expr_root a'
  | _             => None
  end.

(* a store whose lvalue is rooted at a tracked, non-Mario temp. *)
Definition is_chase_store (PT : ident -> bool) (a1 : expr) : bool :=
  match lv_root a1 with
  | Some p => PT p && negb (Pos.eqb p mario._m) && rooted_lv p a1
  | None   => false
  end.

(* a chase-LOAD `m->fid` of a tracked pointer field fid in FS (the exact shape
   set_off_bm_ok_chase_load consumes). *)
Definition is_chase_load (FS : list ident) (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar q t1) t2) fid (Tpointer rty pa) =>
      (if Pos.eq_dec q mario._m then true else false)
      && (if type_eq t1 (tptr (Tstruct mario._MarioState noattr)) then true else false)
      && (if type_eq t2 (Tstruct mario._MarioState noattr) then true else false)
      && (if attr_eq pa noattr then true else false)
      && existsb (Pos.eqb fid) FS
  | _ => false
  end.

Fixpoint body_nf_ok_dec (PT : ident -> bool) (FS : list ident) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn _ | Sgoto _ => true
  | Sassign a1 _ => is_chase_store PT a1
  | Sset id a => negb (Pos.eqb id mario._m) && (negb (PT id) || is_chase_load FS a)
  | Scall None _ _ => true
  | Scall (Some id) _ _ => negb (Pos.eqb id mario._m)
  | Sbuiltin _ _ _ _ => false
  | Ssequence s1 s2 => body_nf_ok_dec PT FS s1 && body_nf_ok_dec PT FS s2
  | Sifthenelse _ s1 s2 => body_nf_ok_dec PT FS s1 && body_nf_ok_dec PT FS s2
  | Sloop s1 s2 => body_nf_ok_dec PT FS s1 && body_nf_ok_dec PT FS s2
  | Slabel _ s1 => body_nf_ok_dec PT FS s1
  | Sswitch _ _ => false
  end.

Lemma is_chase_store_sound :
  forall PT a1, is_chase_store PT a1 = true ->
    exists p, p <> mario._m /\ PT p = true /\ rooted_lv p a1 = true.
Proof.
  intros PT a1 H. unfold is_chase_store in H.
  destruct (lv_root a1) as [p|]; [ | discriminate ].
  apply andb_prop in H. destruct H as [H12 Hr].
  apply andb_prop in H12. destruct H12 as [Hpt Hne].
  exists p. split; [ | split; [ exact Hpt | exact Hr ] ].
  intro He. rewrite He, Pos.eqb_refl in Hne. discriminate Hne.
Qed.

Lemma is_chase_load_sound :
  forall PT FS bm e id a, is_chase_load FS a = true -> set_off_bm_ok PT FS bm e id a.
Proof.
  intros PT FS bm e id a H. unfold is_chase_load in H.
  destruct a; try discriminate H.
  do 3 (match goal with
        | H' : context [ match ?x with _ => _ end ] |- _ => destruct x; try discriminate H'
        end).
  apply andb_prop in H. destruct H as [H1 Hex].
  apply andb_prop in H1. destruct H1 as [H2 Hpa].
  apply andb_prop in H2. destruct H2 as [H3 Ht2].
  apply andb_prop in H3. destruct H3 as [Hq Ht1].
  destruct (Pos.eq_dec _ mario._m) as [Hqm|]; [ | discriminate Hq ].
  destruct (type_eq _ (tptr (Tstruct mario._MarioState noattr))) as [Ht1e|]; [ | discriminate Ht1 ].
  destruct (type_eq _ (Tstruct mario._MarioState noattr)) as [Ht2e|]; [ | discriminate Ht2 ].
  destruct (attr_eq _ noattr) as [Hpae|]; [ | discriminate Hpa ].
  rewrite Hqm, Ht1e, Ht2e, Hpae.
  apply set_off_bm_ok_chase_load.
  apply existsb_exists in Hex. destruct Hex as (x & Hin & Hxe).
  apply Pos.eqb_eq in Hxe. subst x. exact Hin.
Qed.

(* SOUNDNESS: the decidable check implies the semantic frame obligation. *)
Lemma body_nf_ok_dec_sound :
  forall s PT FS bm en, body_nf_ok_dec PT FS s = true -> body_nf_ok PT FS bm en s.
Proof.
  induction s; intros PT FS bm en H; cbn [body_nf_ok_dec] in H; cbn [body_nf_ok];
    try exact I; try discriminate H.
  - (* Sassign *) left. apply is_chase_store_sound. exact H.
  - (* Sset *)
    apply andb_prop in H. destruct H as [Hid Hrest]. split.
    + intro He. rewrite He, Pos.eqb_refl in Hid. discriminate Hid.
    + intro Hpt. apply orb_prop in Hrest. destruct Hrest as [Hn | Hcl].
      * rewrite Hpt in Hn. discriminate Hn.
      * apply is_chase_load_sound. exact Hcl.
  - (* Scall *) destruct o as [id|]; [ | exact I ].
    intro He. rewrite He, Pos.eqb_refl in H. discriminate H.
  - (* Ssequence *) apply andb_prop in H. destruct H as [H1 H2].
    split; [ apply IHs1; exact H1 | apply IHs2; exact H2 ].
  - (* Sifthenelse *) apply andb_prop in H. destruct H as [H1 H2].
    split; [ apply IHs1; exact H1 | apply IHs2; exact H2 ].
  - (* Sloop *) apply andb_prop in H. destruct H as [H1 H2].
    split; [ apply IHs1; exact H1 | apply IHs2; exact H2 ].
  - (* Slabel *) apply IHs; exact H.
Qed.
