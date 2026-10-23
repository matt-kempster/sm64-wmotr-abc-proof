(* ====================================================================== *)
(* PoleStartT (GOAL 2): which of PoleRunT's start variants a pole action   *)
(* starts in, and the walk's start facts about the animation state.        *)
(*                                                                        *)
(* The frame world's AnimWorld.anim_w gives, in a pole action after the    *)
(* grab, anim_st: no handstand animation (nstate) or handstand animation   *)
(* k loaded.  pick turns that into a variant the action's walks cover:     *)
(*   TOP_OF_POLE             AL 9, or AR [9] (9 not loaded);               *)
(*   TOP_OF_POLE_TRANSITION  AL 11, AL 12, or AR [11; 12];                 *)
(*   HOLDING / CLIMBING      AU true (anim_st, kept or re-established);    *)
(*   the two grabs           AU false (nothing known).                    *)
(* nid_holds / caddr_holds are the AR facts' meaning: the walked tests     *)
(* animID != k and currentAddr != &gMarioAnims[hs_off k] are true.         *)
(* ====================================================================== *)

From Coq Require Import List ZArith Lia.
From compcert Require Import Coqlib AST Integers Values Memory Ctypes Cop.
From SM64.Proofs Require Import Interp.SymExec2.
From SM64.Proofs.WMotRRequiresA Require Import AnimData AnimWorld AnimEnd PoleRunT.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

(* the start facts name only the walk's regions *)
Lemma pc0T_nlt : forall acn g v f, In f (pc0T acn g v) -> fact_nlt NBT f.
Proof.
  intros acn g v f H. unfold pc0T in H. apply in_app_or in H as [H | H].
  - cbn [In] in H.
    repeat (destruct H as [<- | H]; [cbn; repeat split; try (unfold Plt; cbn; lia); repeat constructor;
                                     unfold Plt; cbn; lia |]).
    contradiction.
  - destruct v as [st | k | ks]; cbn [av_pc] in H.
    + contradiction.
    + destruct H as [<- | []]. cbn. repeat constructor; unfold Plt; cbn; lia.
    + unfold vfacts in H. apply in_flat_map in H as (k & _ & H).
      destruct H as [<- | [<- | []]]; cbn; repeat split; try (unfold Plt; cbn; lia); exact I.
Qed.

Definition POLE6 : list Z := [1049409; 1049410; 135267136; 1049411; 1049412; 1049413].

(* the variants each pole action's walks cover *)
Definition avars (acn : Z) : list avar :=
  if Z.eqb acn 1049413 then [AL 9; AR [9]]
  else if Z.eqb acn 1049412 then [AL 11; AL 12; AR [11; 12]]
  else if Z.eqb acn 135267136 || Z.eqb acn 1049411 then [AU true]
  else [AU false].

Lemma avars_AL : forall acn k, In (AL k) (avars acn) -> k = 9 \/ k = 11 \/ k = 12.
Proof.
  intros acn k H. unfold avars in H.
  destruct (Z.eqb acn 1049413); [cbn in H; intuition congruence |].
  destruct (Z.eqb acn 1049412); [cbn in H; intuition congruence |].
  destruct (Z.eqb acn 135267136 || Z.eqb acn 1049411); cbn in H; intuition congruence.
Qed.

Lemma avars_AR : forall acn ks, In (AR ks) (avars acn) -> forall k, In k ks -> In k hs_ids.
Proof.
  intros acn ks H k Hk. unfold avars in H.
  destruct (Z.eqb acn 1049413); [cbn in H; destruct H as [H | [H | []]]; try discriminate H;
                                  injection H as <-; cbn in Hk |- *; intuition |].
  destruct (Z.eqb acn 1049412); [cbn in H; destruct H as [H | [H | [H | []]]]; try discriminate H;
                                  injection H as <-; cbn in Hk |- *; intuition |].
  destruct (Z.eqb acn 135267136 || Z.eqb acn 1049411); cbn in H; destruct H as [H | []]; discriminate H.
Qed.

(* AL / AR starts are the top-of-pole actions', which are in anim_acts *)
Lemma avars_LR : forall acn v, In v (avars acn) -> (forall st, v <> AU st) -> In acn anim_acts.
Proof.
  intros acn v H N. unfold avars in H.
  destruct (Z.eqb acn 1049413) eqn:E1; [apply Z.eqb_eq in E1; subst; cbn; tauto |].
  destruct (Z.eqb acn 1049412) eqn:E2; [apply Z.eqb_eq in E2; subst; cbn; tauto |].
  destruct (Z.eqb acn 135267136 || Z.eqb acn 1049411); cbn in H;
    destruct H as [<- | []]; exfalso; exact (N _ eq_refl).
Qed.

(* what a variant asks of the start memory *)
Definition avar_ok (m : mem) (ab bga bt : block) (ot : ptrofs) (mb : block) (mo : ptrofs) (v : avar)
  : Prop :=
  match v with
  | AU st => if st then anim_st m ab bga bt ot mb mo else True
  | AL k => loaded m ab bga bt ot mb mo k
  | AR ks => forall k, In k ks ->
      (exists i, Mem.load Mint16signed m mb (Ptrofs.unsigned mo + 56) = Some (Vint i) /\ Int.signed i <> k)
      /\ (Mem.load Mint32 m ab 4 = Some (Vint Int.zero)
          \/ exists o, Mem.load Mint32 m ab 4 = Some (Vptr bga o) /\ Ptrofs.unsigned o <= GA_SIZE
                       /\ Ptrofs.unsigned o <> hs_off k)
  end.

Lemma hs_ids_cases : forall k, In k hs_ids -> k = 9 \/ k = 11 \/ k = 12.
Proof. intros k H. cbn in H. intuition. Qed.

(* a loaded handstand animation k' other than each k: an AR start *)
Lemma loaded_ar : forall m ab bga bt ot mb mo k' ks, In k' hs_ids ->
  loaded m ab bga bt ot mb mo k' -> (forall k, In k ks -> k <> k' /\ In k hs_ids) ->
  avar_ok m ab bga bt ot mb mo (AR ks).
Proof.
  intros m ab bga bt ot mb mo k' ks Hk' (L4 & L56 & _ & _ & _ & _) Hks k Hk.
  destruct (Hks k Hk) as (Nk & Ik).
  split.
  - exists (Int.repr k'). split; [ exact L56 | ].
    destruct (hs_ids_cases _ Hk') as [-> | [-> | ->]]; rewrite Int.signed_repr;
      first [ exact (not_eq_sym Nk) | unfold Int.min_signed, Int.max_signed; cbn; lia ].
  - right. exists (Ptrofs.repr (hs_off k')). split; [ exact L4 | ].
    destruct (hs_ids_cases _ Hk') as [-> | [-> | ->]]; destruct (hs_ids_cases _ Ik) as [-> | [-> | ->]];
      try congruence; vm_compute; split; congruence.
Qed.

(* no handstand animation: an AR start for any ks of handstand ids *)
Lemma nstate_ar : forall m ab bga bt ot mb mo ks, nstate m ab bga mb mo ->
  (forall k, In k ks -> In k hs_ids) -> avar_ok m ab bga bt ot mb mo (AR ks).
Proof.
  intros m ab bga bt ot mb mo ks ((i & L56 & Ni) & C) Hks k Hk.
  split.
  - exists i. split; [ exact L56 | ]. intros E. apply Ni. rewrite E. exact (Hks k Hk).
  - destruct C as [C | (o & L4 & Ho & No)]; [ left; exact C | right ].
    exists o. split; [ exact L4 | ]. split; [ exact Ho | ].
    intros E. apply No. rewrite E. unfold hs_offs. apply in_map. exact (Hks k Hk).
Qed.

Theorem pick : forall acn m ab bga bt ot mb mo, In acn POLE6 ->
  (In acn anim_acts -> anim_st m ab bga bt ot mb mo) ->
  exists v, In v (avars acn) /\ avar_ok m ab bga bt ot mb mo v.
Proof.
  intros acn m ab bga bt ot mb mo Hp Hs.
  assert (HI : forall k, In k [11; 12] -> In k hs_ids) by (intros k Hk; cbn in *; intuition).
  assert (H9 : forall k, In k [9] -> In k hs_ids) by (intros k Hk; cbn in *; intuition).
  destruct Hp as [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]].
  - exists (AU false). split; [ left; reflexivity | exact I ].
  - exists (AU false). split; [ left; reflexivity | exact I ].
  - exists (AU true). split; [ left; reflexivity | ]. apply Hs. cbn; tauto.
  - exists (AU true). split; [ left; reflexivity | ]. apply Hs. cbn; tauto.
  - destruct (Hs ltac:(cbn; tauto)) as [N | (k & Hk & L)].
    + exists (AR [11; 12]). split; [ cbn; tauto | exact (nstate_ar _ _ _ _ _ _ _ _ N HI) ].
    + destruct (hs_ids_cases _ Hk) as [-> | [-> | ->]].
      * exists (AR [11; 12]). split; [ cbn; tauto | ].
        apply (loaded_ar _ _ _ _ _ _ _ 9 _ Hk L). intros k0 Hk0. split; [ cbn in Hk0; lia | exact (HI k0 Hk0) ].
      * exists (AL 11). split; [ cbn; tauto | exact L ].
      * exists (AL 12). split; [ cbn; tauto | exact L ].
  - destruct (Hs ltac:(cbn; tauto)) as [N | (k & Hk & L)].
    + exists (AR [9]). split; [ cbn; tauto | exact (nstate_ar _ _ _ _ _ _ _ _ N H9) ].
    + destruct (hs_ids_cases _ Hk) as [-> | [-> | ->]].
      * exists (AL 9). split; [ cbn; tauto | exact L ].
      * exists (AR [9]). split; [ cbn; tauto | ].
        apply (loaded_ar _ _ _ _ _ _ _ 11 _ Hk L). intros k0 Hk0. split; [ cbn in Hk0; lia | exact (H9 k0 Hk0) ].
      * exists (AR [9]). split; [ cbn; tauto | ].
        apply (loaded_ar _ _ _ _ _ _ _ 12 _ Hk L). intros k0 Hk0. split; [ cbn in Hk0; lia | exact (H9 k0 Hk0) ].
Qed.

(* the AR facts hold *)
Lemma nid_holds : forall (ce : composite_env) m i k, In k hs_ids -> Int.signed i <> k ->
  exists v, sem_binary_operation ce Cop.One (Vint i) tI16 (Vint (Int.repr k)) tI32 m = Some v
            /\ bool_val v tI32 m = Some true.
Proof.
  intros ce m i k Hk N.
  assert (E : Int.eq i (Int.repr k) = false).
  { destruct (Int.eq i (Int.repr k)) eqn:Q; [ | reflexivity ]. apply Int.same_if_eq in Q. subst i.
    exfalso. apply N. destruct (hs_ids_cases _ Hk) as [-> | [-> | ->]]; reflexivity. }
  cbn. rewrite E. cbn. eexists; split; reflexivity.
Qed.

Lemma vp_ga : forall m bga z, Mem.range_perm m bga 0 GA_SIZE Cur Readable -> 0 <= z < GA_SIZE ->
  Mem.valid_pointer m bga z = true.
Proof.
  intros m bga z P Hz. apply Mem.valid_pointer_nonempty_perm.
  eapply Mem.perm_implies; [ apply P; exact Hz | constructor ].
Qed.

Lemma wvp_ga : forall m bga z, Mem.range_perm m bga 0 GA_SIZE Cur Readable -> 0 <= z <= GA_SIZE ->
  Mem.weak_valid_pointer m bga z = true.
Proof.
  intros m bga z P Hz. unfold Mem.weak_valid_pointer.
  destruct (zlt z GA_SIZE) as [L | L].
  - rewrite (vp_ga m bga z P ltac:(lia)). reflexivity.
  - rewrite (vp_ga m bga (z - 1) P ltac:(unfold GA_SIZE in *; lia)). apply orb_true_r.
Qed.

Lemma caddr_holds : forall (ce : composite_env) m bga off cur,
  Mem.range_perm m bga 0 GA_SIZE Cur Readable -> 0 <= off < GA_SIZE ->
  (cur = Vint Int.zero
   \/ exists o, cur = Vptr bga o /\ Ptrofs.unsigned o <= GA_SIZE /\ Ptrofs.unsigned o <> off) ->
  exists v, sem_binary_operation ce Cop.One (Vptr bga (Ptrofs.repr off)) tpu8 cur tpv m = Some v
            /\ bool_val v tI32 m = Some true.
Proof.
  intros ce m bga off cur P Ho C.
  assert (Ro : Ptrofs.unsigned (Ptrofs.repr off) = off)
    by (apply Ptrofs.unsigned_repr; unfold GA_SIZE in Ho; unfold Ptrofs.max_unsigned; cbn; lia).
  assert (W1 : Mem.weak_valid_pointer m bga (Ptrofs.unsigned (Ptrofs.repr off)) = true)
    by (rewrite Ro; apply wvp_ga; [ exact P | lia ]).
  assert (SB : forall v2, sem_binary_operation ce Cop.One (Vptr bga (Ptrofs.repr off)) tpu8 v2 tpv m
                          = cmp_ptr m Cne (Vptr bga (Ptrofs.repr off)) v2)
    by (intros; reflexivity).
  unfold Mem.weak_valid_pointer in W1.
  destruct C as [-> | (o & -> & Hle & Ne)]; rewrite SB; unfold cmp_ptr; cbv beta iota zeta delta [Archi.ptr64 Val.cmpu_bool].
  - rewrite Int.eq_true, W1. cbn. eexists; split; reflexivity.
  - assert (W2 : Mem.weak_valid_pointer m bga (Ptrofs.unsigned o) = true)
      by (apply wvp_ga; [ exact P | pose proof (Ptrofs.unsigned_range o); lia ]).
    unfold Mem.weak_valid_pointer in W2.
    assert (Q : Ptrofs.eq (Ptrofs.repr off) o = false).
    { destruct (Ptrofs.eq (Ptrofs.repr off) o) eqn:Q; [ | reflexivity ].
      apply Ptrofs.same_if_eq in Q. subst o. rewrite Ro in Ne. congruence. }
    destruct (eq_block bga bga) as [_ | N]; [ | congruence ].
    rewrite W1, W2. cbn [andb option_map]. unfold Ptrofs.cmpu. rewrite Q.
    cbn. eexists; split; reflexivity.
Qed.
