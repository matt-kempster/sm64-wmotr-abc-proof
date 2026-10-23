(* ====================================================================== *)
(* SndXc (GOAL 2): the audio calls the walks reach, as clobber contracts   *)
(* proved from their REAL bodies (the audio link, 2026-10-23).             *)
(*                                                                        *)
(* play_sound and set_sound_moving_speed (audio/external.c, linked) are    *)
(*                                                                        *)
(*   sSoundRequests[sSoundRequestCount].soundBits = soundBits;            *)
(*   sSoundRequests[sSoundRequestCount].position = pos;                   *)
(*   sSoundRequestCount++;                                                *)
(*                                                                        *)
(*   sSoundMovingSpeed[bank] = speed;                                     *)
(*                                                                        *)
(* The store index is whatever memory holds, so the walk cannot run them  *)
(* store by store (sstore needs a concrete offset).  Instead each call is  *)
(* a CLOBBER contract: the regions of the written globals (each of size   *)
(* 2^32 at base 0, so any offset is inside) may hold anything afterwards, *)
(* every other cell is unchanged, and the result is a fresh value.        *)
(* c_snd_sound proves it from the generated body: AudioBodies.fp_body      *)
(* walks it (every store lands in a named global's block), and the        *)
(* footprint gives SmaXc.sstores_havoc_cl's frame premise.                *)
(*                                                                        *)
(* This replaces the labeled open premise ExtInert.audio_inert (deleted). *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events
  Globalenvs Ctypes Clight ClightBigstep.
From SM64.Generated Require audio_external.
From SM64.Proofs Require Import Interp.SymExec2 MarioModel.RealFrameLinked.
From SM64.Proofs Require Import MarioModel.AudioBodies.
From SM64.Proofs Require Import CensusV2.
From SM64.Proofs.WMotRRequiresA Require Import WallExec SmaXc.
Import ListNotations.

Module AX := audio_external.

Section CS.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).

(* each (global, region): the region is the global's, of size 2^32 *)
Definition snd_ok (ps : list (ident * positive)) : bool :=
  forallb (fun p => match gfind gtab (fst p) with Some r => Pos.eqb r (snd p) | None => false end
                    && match r0_size R0 (snd p) with
                       | Some sz => Z.eqb sz Ptrofs.modulus | None => false end) ps.

Definition c_snd (ps : list (ident * positive)) : xcontract :=
  fun _ g =>
    if snd_ok ps && forallb (fun e => negb (existsb (Pos.eqb (sreg e)) (map snd ps))) (g_sm g)
    then let g1 := gcl (map snd ps) g in Some [(gfresh g1, Sfresh (g_nx g1))]
    else None.
End CS.

(* the two bodies' footprints, as AudioBodies.fp_body walks them *)
Definition ps_globals : list ident := [AX._sSoundRequests; AX._sSoundRequestCount].
Definition ssms_globals : list ident := [AX._sSoundMovingSpeed].

Lemma ps_walk : lw_chk (fun _ _ => true) (fp_store_ok ps_globals) (fun _ _ _ => false)
                  (fn_body AX.f_play_sound) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma ssms_walk : lw_chk (fun _ _ => true) (fp_store_ok ssms_globals) (fun _ _ _ => false)
                    (fn_body AX.f_set_sound_moving_speed) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma ssms_defmap :
  (prog_defmap AX.prog) ! AX._set_sound_moving_speed
    = Some (Gfun (Internal AX.f_set_sound_moving_speed)).
Proof. vm_compute. reflexivity. Qed.
Lemma ps_defmap :
  (prog_defmap AX.prog) ! AX._play_sound = Some (Gfun (Internal AX.f_play_sound)).
Proof. vm_compute. reflexivity. Qed.

Section SND.
Variable lp : Clight.program.
Local Notation G := (globalenv lp).
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).

Local Notation MM := (MMg G nbase R0 gtab kv m0 uf gp).

Theorem c_snd_sound : forall ps f,
  fn_vars f = nil -> fn_return f = Tvoid ->
  lw_chk (fun _ _ => true) (fp_store_ok (map fst ps)) (fun _ _ _ => false) (fn_body f) = true ->
  forall args g cps E m vargs t m' vres,
  c_snd R0 gtab ps args g = Some cps ->
  MM E m g ->
  eval_funcall function_entry2 G m (Internal f) vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros ps f Hv Hr Hw args g cps E m vargs t m' vres Hc MMh Hev.
  unfold c_snd in Hc.
  destruct (snd_ok R0 gtab ps
            && forallb (fun e => negb (existsb (Pos.eqb (sreg e)) (map snd ps))) (g_sm g)) eqn:CK;
    [ | discriminate Hc ].
  injection Hc as <-.
  apply andb_true_iff in CK as [SO NCLb].
  set (cls := map snd ps).
  set (g1 := gcl cls g).
  pose proof (MM_gcl G nbase R0 gtab kv m0 uf gp cls E m g MMh) as M1. fold g1 in M1.
  pose proof MMh as (EO & _). pose proof EO as (A1 & A2 & A3 & A4 & _).
  (* each named global's block is its region's *)
  assert (PS : forall p, In p ps ->
            Genv.find_symbol G (fst p) = Some (e_blk E (snd p)) /\ e_base E (snd p) = Ptrofs.zero
            /\ r0_size R0 (snd p) = Some Ptrofs.modulus).
  { intros p Ip. pose proof (proj1 (forallb_forall _ _) SO p Ip) as X. cbn beta in X.
    apply andb_true_iff in X as [X1 X2].
    destruct (gfind gtab (fst p)) as [r|] eqn:Gf; [ | discriminate X1 ].
    apply Pos.eqb_eq in X1. subst r.
    destruct (A4 _ _ Gf) as (_ & Bz & Hs).
    destruct (r0_size R0 (snd p)) as [sz|] eqn:Sz; [ | discriminate X2 ].
    apply Z.eqb_eq in X2. subst sz. auto. }
  set (blks := map (fun p => e_blk E (snd p)) ps).
  assert (Hblks : forall g0 b, mem_id g0 (map fst ps) = true ->
            Genv.find_symbol (lp_ge lp) g0 = Some b -> In b blks).
  { intros g0 b Hm Hs. unfold mem_id in Hm. apply existsb_exists in Hm as (x & Ix & Ex).
    apply Pos.eqb_eq in Ex. subst x. apply in_map_iff in Ix as (p & Ep & Ip). subst g0.
    destruct (PS p Ip) as (Hs' & _). unfold lp_ge in Hs. rewrite Hs in Hs'. injection Hs' as ->.
    unfold blks. exact (in_map (fun p => e_blk E (snd p)) ps p Ip). }
  destruct (fp_body lp (map fst ps) blks Hblks m f Hv Hw vargs t m' vres Hev) as (U & N & P).
  assert (CLS : forall rc, In rc cls -> In rc (g_cl g1) /\ exists sz, r0_size R0 rc = Some sz).
  { intros rc Ic. split; [ unfold g1; cbn [gcl g_cl]; apply in_or_app; left; exact Ic | ].
    unfold cls in Ic. apply in_map_iff in Ic as (p & <- & Ip).
    destruct (PS p Ip) as (_ & _ & S). eauto. }
  assert (NCL : forall e, In e (g_sm g1) -> ~ In (sreg e) cls).
  { intros e Ie Ic. unfold g1 in Ie. cbn [gcl g_sm] in Ie.
    pose proof (proj1 (forallb_forall _ _) NCLb e Ie) as X. apply negb_true_iff in X.
    assert (Y : existsb (Pos.eqb (sreg e)) cls = true)
      by (apply existsb_exists; exists (sreg e); split; [ exact Ic | apply Pos.eqb_refl ]).
    unfold cls in Y. congruence. }
  assert (HD : forall b z ch, Mem.valid_block m b ->
            (forall k, In k (@nil sentry) -> cell_disj E (skey k) b z ch) ->
            (forall rc, In rc cls -> rng_disj R0 E rc b z ch) ->
            Mem.load ch m' b z = Mem.load ch m b z).
  { intros b z ch V _ C.
    eapply Mem.load_unchanged_on_1; [ exact U | exact V | ].
    intros i Hi (Ib & Hz).
    unfold blks in Ib. apply in_map_iff in Ib as (p & Eb & Ip).
    destruct (PS p Ip) as (_ & Bz & Sz).
    pose proof (C (snd p) (in_map _ _ _ Ip)) as X. unfold rng_disj in X.
    rewrite Sz, Bz, Ptrofs.unsigned_zero in X. lia. }
  destruct (sstores_havoc_cl G nbase R0 gtab kv m0 uf gp gp_old cls E m g1 [] g1 m'
              M1 CLS NCL eq_refl ltac:(intros r o ch sv []) HD
              ltac:(rewrite N; apply Ple_refl) ltac:(intros b o k p _; apply P))
    as (M' & _ & _ & _).
  assert (VO : val_old gp vres) by (rewrite (void_ret _ _ _ _ _ _ _ Hr Hev); exact I).
  destruct (fresh_cm G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m' g1 vres M' VO)
    as (E3 & X3 & M3 & D3 & SK3 & PL3 & LC3).
  exists (gfresh g1, Sfresh (g_nx g1)). split; [ left; reflexivity | ].
  exists E3. split; [ exact X3 | split; [ exact M3 | split; [ exact D3 | split; [ exact SK3 | split ] ] ] ].
  - exact PL3.
  - rewrite LC3. reflexivity.
Qed.

(* the two instances *)
Theorem c_ps_sound : forall rsr rsrc args g cps E m vargs t m' vres,
  c_snd R0 gtab [(AX._sSoundRequests, rsr); (AX._sSoundRequestCount, rsrc)] args g = Some cps ->
  MM E m g ->
  eval_funcall function_entry2 G m (Internal AX.f_play_sound) vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros rsr rsrc. apply c_snd_sound; [ reflexivity | reflexivity | exact ps_walk ].
Qed.
Theorem c_ssms_sound : forall rsms args g cps E m vargs t m' vres,
  c_snd R0 gtab [(AX._sSoundMovingSpeed, rsms)] args g = Some cps ->
  MM E m g ->
  eval_funcall function_entry2 G m (Internal AX.f_set_sound_moving_speed) vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros rsms. apply c_snd_sound; [ reflexivity | reflexivity | exact ssms_walk ].
Qed.
End SND.
