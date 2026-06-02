(* BodyFrameDecider.v -- a DECIDABLE frame check, and its soundness.
 *
 * body_nf_ok (StatementFrame) is the per-statement obligation the frame consumes;
 * proving it per function is currently a hand-written `all: try solve [...]`
 * dispatcher. This file replaces that with a COMPUTABLE predicate body_nf_ok_dec
 * and proves body_nf_ok_dec PT FS s = true -> body_nf_ok PT FS bm e s. So a
 * function's frame obligation becomes a `vm_compute; reflexivity` -- the syntactic
 * skeleton of the static rootedness analysis (PT/FS are still supplied per fn; an
 * automatic dataflow deriving them, plus the locally_safe connection, is the next
 * step). Scope: straight-line + branches + loops + calls; Sswitch is rejected for
 * now (switch fns keep their dispatcher), keeping soundness a single induction.
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs
  Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import List Bool.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying FieldNonInterference ActionValueFrame MarioMemoryWF
  ResetBodystate RootedLvalue TempProvenanceInvariant StatementFrame.

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

(* `tid = &q->...` -- addrof of an lvalue rooted at a tracked temp. *)
Definition is_addrof_rooted (PT : ident -> bool) (a : expr) : bool :=
  match a with
  | Eaddrof lv _ =>
      match lv_root lv with
      | Some q => PT q && negb (Pos.eqb q mario._m) && rooted_lv q lv
      | None => false
      end
  | _ => false
  end.

(* `tid = q` -- copy of a tracked temp. *)
Definition is_tempcopy (PT : ident -> bool) (a : expr) : bool :=
  match a with
  | Etempvar q _ => PT q && negb (Pos.eqb q mario._m)
  | _ => false
  end.

(* the rhs of an Sset into a TRACKED temp must keep it off-bm: a chase-load of a
   tracked pointer field, an addrof inside a tracked block, or a tracked-temp copy. *)
Definition is_safe_set (PT : ident -> bool) (FS : list ident) (a : expr) : bool :=
  is_chase_load FS a || is_addrof_rooted PT a || is_tempcopy PT a.

(* two byte-ranges [o1,o1+s1) and [o2,o2+s2) are disjoint. *)
Definition range_disjoint (o1 s1 o2 s2 : Z) : bool :=
  Z.leb (o1 + s1) o2 || Z.leb (o2 + s2) o1.

(* a DIRECT scalar store `m->fid = rhs` whose written range misses the watch set:
   the action cell [12,12+|Mint32|) and every chased field's load range
   [off',off'+|Mptr|). All offsets/sizes computed from mario_ce (no globalenv). *)
Definition is_safe_direct (FS : list ident) (a1 : expr) : bool :=
  match a1 with
  | Efield (Ederef (Etempvar q t1) t2) fid ty =>
      (if Pos.eq_dec q mario._m then true else false)
      && (if type_eq t1 (tptr (Tstruct mario._MarioState noattr)) then true else false)
      && (if type_eq t2 (Tstruct mario._MarioState noattr) then true else false)
      && match field_offset mario_ce fid mario_members with
         | OK (off, Full) =>
             Z.leb 0 off && Z.leb off Ptrofs.max_unsigned
             && range_disjoint off (Ctypes.sizeof mario_ce ty) 12 (size_chunk Mint32)
             && forallb (fun fid' =>
                  match field_offset mario_ce fid' mario_members with
                  | OK (o2, Full) =>
                      range_disjoint off (Ctypes.sizeof mario_ce ty) o2 (size_chunk Mptr)
                  | _ => false
                  end) FS
         | _ => false
         end
  | _ => false
  end.

Fixpoint body_nf_ok_dec (PT : ident -> bool) (FS : list ident) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn _ | Sgoto _ => true
  | Sassign a1 _ => is_chase_store PT a1 || is_safe_direct FS a1
  | Sset id a => negb (Pos.eqb id mario._m) && (negb (PT id) || is_safe_set PT FS a)
  | Scall None _ _ => true
  | Scall (Some id) _ _ => negb (Pos.eqb id mario._m)
  | Sbuiltin _ _ _ _ => false
  | Ssequence s1 s2 => body_nf_ok_dec PT FS s1 && body_nf_ok_dec PT FS s2
  | Sifthenelse _ s1 s2 => body_nf_ok_dec PT FS s1 && body_nf_ok_dec PT FS s2
  | Sloop s1 s2 => body_nf_ok_dec PT FS s1 && body_nf_ok_dec PT FS s2
  | Slabel _ s1 => body_nf_ok_dec PT FS s1
  | Sswitch _ ls => ls_dec PT FS ls
  end
with ls_dec (PT : ident -> bool) (FS : list ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons _ s rest => body_nf_ok_dec PT FS s && ls_dec PT FS rest
  end.

Scheme statement_ind2 := Induction for statement Sort Prop
  with ls_ind2 := Induction for labeled_statements Sort Prop.
Combined Scheme stmt_ls_ind from statement_ind2, ls_ind2.

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

Lemma is_addrof_rooted_sound :
  forall PT FS bm e id a, is_addrof_rooted PT a = true -> set_off_bm_ok PT FS bm e id a.
Proof.
  intros PT FS bm e id a H. unfold is_addrof_rooted in H.
  destruct a; try discriminate H.
  destruct (lv_root _) as [q|]; [ | discriminate H ].
  apply andb_prop in H. destruct H as [H1 Hroot].
  apply andb_prop in H1. destruct H1 as [Hpt Hne].
  eapply set_off_bm_ok_addrof_rooted.
  - exact Hpt.
  - intro He. rewrite He, Pos.eqb_refl in Hne. discriminate Hne.
  - exact Hroot.
Qed.

Lemma is_tempcopy_sound :
  forall PT FS bm e id a, is_tempcopy PT a = true -> set_off_bm_ok PT FS bm e id a.
Proof.
  intros PT FS bm e id a H. unfold is_tempcopy in H.
  destruct a; try discriminate H.
  apply andb_prop in H. destruct H as [Hpt Hne].
  apply set_off_bm_ok_tempcopy.
  - exact Hpt.
  - intro He. rewrite He, Pos.eqb_refl in Hne. discriminate Hne.
Qed.

Lemma is_safe_set_sound :
  forall PT FS bm e id a, is_safe_set PT FS a = true -> set_off_bm_ok PT FS bm e id a.
Proof.
  intros PT FS bm e id a H. unfold is_safe_set in H.
  apply orb_prop in H. destruct H as [H | Htc].
  - apply orb_prop in H. destruct H as [Hcl | Har].
    + apply is_chase_load_sound; exact Hcl.
    + apply is_addrof_rooted_sound; exact Har.
  - apply is_tempcopy_sound; exact Htc.
Qed.

Lemma sizeof_mario : forall ty, sizeof mario_ge ty = Ctypes.sizeof mario_ce ty.
Proof. intro ty. rewrite genv_cenv_mario. reflexivity. Qed.

Lemma is_safe_direct_sound :
  forall FS bm e a1, is_safe_direct FS a1 = true -> assign_avoids_m (watch FS bm) bm e a1.
Proof.
  intros FS bm e a1 H. unfold is_safe_direct in H.
  destruct a1; try discriminate H.
  do 2 (match goal with
        | H' : context [ match ?x with _ => _ end ] |- _ => destruct x; try discriminate H'
        end).
  apply andb_prop in H. destruct H as [H1 Hmatch].
  apply andb_prop in H1. destruct H1 as [H2 Ht2].
  apply andb_prop in H2. destruct H2 as [Hq Ht1].
  destruct (Pos.eq_dec _ mario._m) as [Hqm|]; [ | discriminate Hq ].
  destruct (type_eq _ (tptr (Tstruct mario._MarioState noattr))) as [Ht1e|]; [ | discriminate Ht1 ].
  destruct (type_eq _ (Tstruct mario._MarioState noattr)) as [Ht2e|]; [ | discriminate Ht2 ].
  destruct (field_offset mario_ce _ mario_members) as [[off bf]|] eqn:Hfo;
    try discriminate Hmatch.
  destruct bf; try discriminate Hmatch.
  apply andb_prop in Hmatch. destruct Hmatch as [Hbr Hforall].
  apply andb_prop in Hbr. destruct Hbr as [Hbnd Hact].
  apply andb_prop in Hbnd. destruct Hbnd as [Hb0 Hbmax].
  rewrite Hqm, Ht1e, Ht2e.
  eapply assign_avoids_m_field; [ exact Hfo | | ].
  - split; [ apply Z.leb_le; exact Hb0 | apply Z.leb_le; exact Hbmax ].
  - intros j Hj. rewrite sizeof_mario in Hj. intro Hw.
    destruct Hw as [Hac | Hch].
    + destruct Hac as [_ Hr]. change (size_chunk Mint32) with 4 in Hr.
      unfold range_disjoint in Hact. change (size_chunk Mint32) with 4 in Hact.
      apply orb_prop in Hact. destruct Hact as [Hd|Hd]; apply Z.leb_le in Hd; lia.
    + destruct Hch as (_ & fid' & off' & Hin & Hfo' & Hrange).
      change (size_chunk Mptr) with 4 in Hrange.
      rewrite forallb_forall in Hforall. specialize (Hforall fid' Hin).
      rewrite Hfo' in Hforall. unfold range_disjoint in Hforall.
      change (size_chunk Mptr) with 4 in Hforall.
      apply orb_prop in Hforall. destruct Hforall as [Hd|Hd]; apply Z.leb_le in Hd; lia.
Qed.

(* SOUNDNESS (mutual over statement / labeled_statements): the decidable check
   implies the semantic frame obligation. *)
Lemma dec_sound_mut :
  (forall s PT FS bm en, body_nf_ok_dec PT FS s = true -> body_nf_ok PT FS bm en s)
  /\ (forall sl PT FS bm en, ls_dec PT FS sl = true -> ls_body_nf_ok PT FS bm en sl).
Proof.
  apply stmt_ls_ind.
  - (* Sskip *) intros; exact I.
  - (* Sassign a1 a2 *) intros a1 a2 PT FS bm en H.
    cbn [body_nf_ok_dec] in H; cbn [body_nf_ok].
    apply orb_prop in H. destruct H as [Hcs | Hsd].
    + left. apply is_chase_store_sound. exact Hcs.
    + right. apply is_safe_direct_sound. exact Hsd.
  - (* Sset id a *) intros id a PT FS bm en H.
    cbn [body_nf_ok_dec] in H; cbn [body_nf_ok].
    apply andb_prop in H. destruct H as [Hid Hrest]. split.
    + intro He. rewrite He, Pos.eqb_refl in Hid. discriminate Hid.
    + intro Hpt. apply orb_prop in Hrest. destruct Hrest as [Hn | Hcl].
      * rewrite Hpt in Hn. discriminate Hn.
      * apply is_safe_set_sound. exact Hcl.
  - (* Scall optid a args *) intros optid a args PT FS bm en H.
    cbn [body_nf_ok_dec] in H; cbn [body_nf_ok].
    destruct optid as [id|]; [ | exact I ].
    intro He. rewrite He, Pos.eqb_refl in H. discriminate H.
  - (* Sbuiltin *) intros optid ef tyargs args PT FS bm en H.
    cbn [body_nf_ok_dec] in H. discriminate H.
  - (* Ssequence s1 s2 *) intros s1 IH1 s2 IH2 PT FS bm en H.
    cbn [body_nf_ok_dec] in H; cbn [body_nf_ok].
    apply andb_prop in H. destruct H as [H1 H2].
    split; [ apply IH1; exact H1 | apply IH2; exact H2 ].
  - (* Sifthenelse a s1 s2 *) intros a s1 IH1 s2 IH2 PT FS bm en H.
    cbn [body_nf_ok_dec] in H; cbn [body_nf_ok].
    apply andb_prop in H. destruct H as [H1 H2].
    split; [ apply IH1; exact H1 | apply IH2; exact H2 ].
  - (* Sloop s1 s2 *) intros s1 IH1 s2 IH2 PT FS bm en H.
    cbn [body_nf_ok_dec] in H; cbn [body_nf_ok].
    apply andb_prop in H. destruct H as [H1 H2].
    split; [ apply IH1; exact H1 | apply IH2; exact H2 ].
  - (* Sbreak *) intros; exact I.
  - (* Scontinue *) intros; exact I.
  - (* Sreturn o *) intros; exact I.
  - (* Sswitch a sl *) intros a sl IHsl PT FS bm en H.
    cbn [body_nf_ok_dec] in H; cbn [body_nf_ok].
    apply IHsl. exact H.
  - (* Slabel lbl s *) intros lbl s IH PT FS bm en H.
    cbn [body_nf_ok_dec] in H; cbn [body_nf_ok].
    apply IH. exact H.
  - (* Sgoto lbl *) intros; exact I.
  - (* LSnil *) intros; exact I.
  - (* LScons c s sl *) intros c s IHs sl IHsl PT FS bm en H.
    cbn [ls_dec] in H; cbn [ls_body_nf_ok].
    apply andb_prop in H. destruct H as [H1 H2].
    split; [ apply IHs; exact H1 | apply IHsl; exact H2 ].
Qed.

Lemma body_nf_ok_dec_sound :
  forall s PT FS bm en, body_nf_ok_dec PT FS s = true -> body_nf_ok PT FS bm en s.
Proof. apply (proj1 dec_sound_mut). Qed.
