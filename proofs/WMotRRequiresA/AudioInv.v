(* kept: the scoped load_sequence footprint (2026-11-02).  ls_frame_ai
   replaces LsContract.ls_frame (FALSE as stated, unscoped) on the spine in
   the deferred root rebuild, where FfWorld.lvl_w gains aud_w (this
   AudioInv) and every phase carries it. *)
(* ====================================================================== *)
(* AudioInv.v -- what load_sequence's footprint relies on, made concrete. *)
(*                                                                        *)
(* LsContract's header reads the real US load.c / heap.c / seqplayer.c:  *)
(* every store lands in the ls_ids blocks (gAudioLoadLock,                *)
(* gSequencePlayers, the two loaded pools, gAudioHeap) or in load.c       *)
(* globals with no block in the model, given the audio driver's own        *)
(* invariants: the pointers it chases (pool cursors, a player's channel  *)
(* pointers, note / layer / bank pointers, all soundAlloc'd from          *)
(* gAudioHeap) stay inside the audio state.  LsContract.ls_frame claimed  *)
(* the footprint for EVERY memory, so it ranged over memories where those *)
(* pointers aim at, e.g., Mario's object (FALSE as stated, unscoped).     *)
(*                                                                        *)
(* AudioInv is that driver invariant at the model's level: a pointer      *)
(* loaded from an ls_ids block points into an audio block (aud_ids =       *)
(* ls_ids plus gSequenceChannelNone, the "no channel" sentinel a player's *)
(* channel slots hold once disabled).  The audio driver's other globals    *)
(* (gSequenceChannels, gSequenceLayers, gNotes, ...) are not declared by  *)
(* any linked TU, so the model has no block for them (TRUST 4.1).          *)
(*                                                                        *)
(* ls_frame_ai is the scoped contract: from an AudioInv memory the call   *)
(* changes only the ls_ids blocks and keeps AudioInv.  aud_chk decides    *)
(* AudioInv on a concrete memory (AudioBoot runs it on the boot images).  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Maps AST Integers Values Memory Memdata Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Generated Require audio_external.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked.
From SM64.Proofs Require EngineV2Consumer.
From SM64.Proofs.WMotRRequiresA Require Import BodyFrame LsContract.
Import ListNotations.
Local Open Scope Z_scope.

Module AX := audio_external.

(* the audio blocks a pointer stored in the audio state may aim at *)
Definition aud_ids : list ident := ls_ids ++ [AX._gSequenceChannelNone].

(* THE INVARIANT *)
Definition AudioInv (G : genv) (m : mem) : Prop :=
  forall b ch z b' o, gblk G ls_ids b -> Mem.load ch m b z = Some (Vptr b' o) -> gblk G aud_ids b'.

(* THE SCOPED CONTRACT (TRUST 4.1, the labeled audio premise's footprint
   half): from an AudioInv memory, load_sequence changes only the ls_ids
   blocks (memory may grow, the new blocks freed) and keeps AudioInv *)
Definition ls_frame_ai (lp : Clight.program) : Prop :=
  forall fd m vargs t m' vres,
    eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres ->
    EngineV2Consumer.resolves_lp lp AX._load_sequence fd ->
    AudioInv (lp_ge lp) m ->
    Q2 (fun b _ => ~ gblk (lp_ge lp) ls_ids b) m m' /\ AudioInv (lp_ge lp) m'.

(* AudioInv reads only the ls_ids blocks *)
Lemma AudioInv_unch : forall G m m',
    (forall b ch z, gblk G ls_ids b -> Mem.load ch m' b z = Mem.load ch m b z) ->
    AudioInv G m -> AudioInv G m'.
Proof.
  intros G m m' U A b ch z b' o Hb Hl. rewrite (U b ch z Hb) in Hl. exact (A b ch z b' o Hb Hl).
Qed.

(* a footprint that keeps the ls_ids blocks keeps AudioInv *)
Lemma AudioInv_Q2 : forall G (P : block -> Z -> Prop) m m',
    (forall b z, gblk G ls_ids b -> P b z) -> Q2 P m m' -> AudioInv G m -> AudioInv G m'.
Proof.
  intros G P m m' HP HQ. apply AudioInv_unch. intros b ch z Hb.
  apply (Q2_load _ _ _ HQ). intros i _. exact (HP b i Hb).
Qed.

(* ---------------------------------------------------------------------- *)
(* The decision procedure.                                                 *)
(* ---------------------------------------------------------------------- *)

Definition gblocks (G : genv) (ids : list ident) : list block :=
  flat_map (fun id => match Genv.find_symbol G id with Some b => [b] | None => nil end) ids.

Lemma gblocks_spec : forall G ids b, In b (gblocks G ids) <-> gblk G ids b.
Proof.
  intros G ids b. unfold gblocks, gblk. rewrite in_flat_map. split.
  - intros (id & Hin & Hb). destruct (Genv.find_symbol G id) as [b0|] eqn:E; [ | destruct Hb ].
    destruct Hb as [<- | []]. exists id. split; assumption.
  - intros (id & Hin & Hs). exists id. split; [ exact Hin | rewrite Hs; left; reflexivity ].
Qed.

Definition okv (A : list block) (mv : memval) : bool :=
  match mv with Fragment (Vptr b' _) _ _ => existsb (Pos.eqb b') A | _ => true end.

Definition blk_ok (A : list block) (c : ZMap.t memval) : bool :=
  okv A (fst c) && forallb (fun p => okv A (snd p)) (PTree.elements (snd c)).

Definition aud_chk (G : genv) (m : mem) : bool :=
  let A := gblocks G aud_ids in
  forallb (fun b => blk_ok A ((Mem.mem_contents m) !! b)) (gblocks G ls_ids).

Lemma blk_ok_get : forall A c z, blk_ok A c = true -> okv A (ZMap.get z c) = true.
Proof.
  intros A [d t] z H. unfold blk_ok in H. cbn [fst snd] in H. apply andb_prop in H as [Hd Ht].
  unfold ZMap.get, PMap.get. cbn [fst snd].
  destruct (t ! (ZIndexed.index z)) as [v|] eqn:E; [ | exact Hd ].
  apply PTree.elements_correct in E.
  exact (proj1 (forallb_forall _ _) Ht _ E).
Qed.

(* a loaded pointer is the first byte's fragment *)
Lemma decode_vptr : forall ch vl b o, decode_val ch vl = Vptr b o ->
    exists q n vl', vl = Fragment (Vptr b o) q n :: vl'.
Proof.
  Ltac nov H := cbn in H; try (unfold Archi.ptr64 in H; cbn in H);
    try (unfold Val.norm_bool in H; cbn in H);
    repeat match type of H with context [if ?c then _ else _] => destruct c end;
    try discriminate H.
  intros ch vl b o H. unfold decode_val in H.
  destruct (proj_bytes vl) as [bl|] eqn:Eb.
  - destruct ch; nov H.
  - assert (Hpv : forall q, proj_value q vl = Vptr b o ->
                   exists q0 n vl', vl = Fragment (Vptr b o) q0 n :: vl').
    { intros q Hl. unfold proj_value in Hl.
      destruct vl as [| [| | v q0 n] vl']; try discriminate Hl.
      destruct (check_value (size_quantity_nat q) v q (Fragment v q0 n :: vl')); [ | discriminate Hl ].
      subst v. eauto. }
    destruct ch; nov H;
      match type of H with context [proj_value ?q vl] =>
        destruct (proj_value q vl) eqn:Ep; nov H; injection H as -> ->; exact (Hpv _ Ep) end.
Qed.

Theorem aud_chk_sound : forall G m, aud_chk G m = true -> AudioInv G m.
Proof.
  intros G m H b ch z b' o Hb Hl.
  apply Mem.load_result in Hl.
  destruct (decode_vptr _ _ _ _ (eq_sym Hl)) as (q & n & vl' & E).
  assert (Hn : size_chunk_nat ch = S (pred (size_chunk_nat ch))).
  { pose proof (size_chunk_pos ch). unfold size_chunk_nat. lia. }
  rewrite Hn in E. cbn [Mem.getN] in E. injection E as Ez _.
  pose proof (proj1 (forallb_forall _ _) H b (proj2 (gblocks_spec _ _ _) Hb)) as Hk.
  pose proof (blk_ok_get _ _ z Hk) as Hv. rewrite Ez in Hv. cbn [okv] in Hv.
  apply existsb_exists in Hv as (x & Hx & Ex). apply Pos.eqb_eq in Ex. subst x.
  exact (proj1 (gblocks_spec _ _ _) Hx).
Qed.
