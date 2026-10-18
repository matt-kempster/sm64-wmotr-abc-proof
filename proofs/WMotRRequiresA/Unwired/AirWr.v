(* ====================================================================== *)
(* AirWr (unwired, GOAL 2): the write-set contract.                        *)
(*                                                                        *)
(* c_wr ws answers a void call whose first argument points at a region:  *)
(* afterwards the cells ws (offset from the pointer, chunk) hold fresh   *)
(* values, and nothing else in memory has changed.  It is SOUND for any  *)
(* callee whose execution has that footprint (FpWalk.fp), which FpWalk   *)
(* proves from the generated body.  So a callee the executor cannot run  *)
(* (update_air_without_turn reads gSineTable at a computed index) is     *)
(* still answered from its real code.                                    *)
(*                                                                        *)
(* The cells hold non-pointer chunks only, so a fresh value never points *)
(* at a block the start memory did not have.                             *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Proofs Require Import Interp.SymExec2 WMotRRequiresA.Unwired.WallExec
  WMotRRequiresA.Unwired.FpWalk.
Import ListNotations.

Definition wset : Type := list (Z * memory_chunk).

Definition chunk_np (ch : memory_chunk) : bool :=
  match ch with
  | Mint8signed | Mint8unsigned | Mint16signed | Mint16unsigned | Mfloat32 | Mfloat64 => true
  | _ => false
  end.

Definition wsizes (ws : wset) : list (Z * Z) := map (fun c => (fst c, size_chunk (snd c))) ws.

Fixpoint wentries (rp : positive) (o0 : Z) (n : positive) (ws : wset) : list sentry :=
  match ws with
  | [] => []
  | (d, ch) :: ws' => (rp, o0 + d, ch, Sfresh n) :: wentries rp o0 (Pos.succ n) ws'
  end.

Fixpoint freshn (k : nat) (g : gst) : gst :=
  match k with O => g | S k' => freshn k' (gfresh g) end.

Definition c_wr (nbase : positive) (R0 : list (positive * Z)) (ws : wset) : xcontract :=
  fun args g =>
  match args with
  | Sptr rp op :: _ =>
      if forallb (fun c => chunk_np (snd c)) ws then
        match sstores nbase R0 (freshn (length ws) g) (wentries rp (Ptrofs.unsigned op) (g_nx g) ws) with
        | Some g' => Some [(g', Sconst Vundef)]
        | None => None
        end
      else None
  | _ => None
  end.

(* ---- the bookkeeping ---- *)

Lemma freshn_meta : forall k g,
  g_sm (freshn k g) = g_sm g /\ g_pc (freshn k g) = g_pc g /\ g_loc (freshn k g) = g_loc g
  /\ g_cl (freshn k g) = g_cl g /\ Ple (g_nx g) (g_nx (freshn k g)).
Proof.
  induction k as [| k IH]; intros g; cbn [freshn].
  - repeat split; apply Ple_refl.
  - destruct (IH (gfresh g)) as (A & B & C & D & F). cbn [gfresh g_sm g_pc g_loc g_cl g_nx] in *.
    repeat split; auto. eapply Ple_trans; [apply Ple_succ | exact F].
Qed.

Lemma freshn_nx : forall k g, g_nx (freshn (S k) g) = g_nx (freshn k (gfresh g)).
Proof. reflexivity. Qed.

Lemma wentries_in : forall rp o0 ws n g e, g_nx g = n -> In e (wentries rp o0 n ws) ->
  exists d ch k, e = (rp, o0 + d, ch, Sfresh k) /\ In (d, ch) ws
                 /\ Ple n k /\ Plt k (g_nx (freshn (length ws) g)).
Proof.
  induction ws as [| [d ch] ws IH]; intros n g e Hn I; [destruct I |].
  cbn [wentries] in I. destruct I as [<- | I].
  - exists d, ch, n. split; [reflexivity | split; [left; reflexivity | split; [apply Ple_refl |]]].
    cbn [length]. rewrite freshn_nx.
    pose proof (proj2 (proj2 (proj2 (proj2 (freshn_meta (length ws) (gfresh g)))))) as L.
    cbn [gfresh g_nx] in L. rewrite <- Hn. unfold Plt, Ple in *. lia.
  - destruct (IH (Pos.succ n) (gfresh g) e ltac:(cbn [gfresh g_nx]; congruence) I)
      as (d' & ch' & k & -> & Iw & L1 & L2).
    exists d', ch', k. split; [reflexivity | split; [right; exact Iw | split]].
    + unfold Plt, Ple in *. lia.
    + exact L2.
Qed.

Lemma uadd_small : forall p d, 0 <= Ptrofs.unsigned p + d < Ptrofs.modulus ->
  Ptrofs.unsigned (Ptrofs.add p (Ptrofs.repr d)) = Ptrofs.unsigned p + d.
Proof.
  intros p d H. rewrite Ptrofs.add_unsigned, Ptrofs.unsigned_repr_eq, (Ptrofs.unsigned_repr_eq d),
    Zplus_mod_idemp_r. apply Z.mod_small. exact H.
Qed.

Lemma wentries_has : forall rp o0 ws n d ch, In (d, ch) ws ->
  exists k, In (rp, o0 + d, ch, Sfresh k) (wentries rp o0 n ws).
Proof.
  induction ws as [| [d1 ch1] ws IH]; intros n d ch Iw; [destruct Iw |].
  destruct Iw as [E1 | Iw].
  - injection E1 as <- <-. exists n. left. reflexivity.
  - destruct (IH (Pos.succ n) d ch Iw) as (k & Ik). exists k. right. exact Ik.
Qed.

Section WR.
Variable ge : genv.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).
Local Notation den := (den ge m0).

Lemma np_load_old : forall ch M b z v, chunk_np ch = true -> Mem.load ch M b z = Some v ->
  val_old gp v.
Proof.
  intros ch M b z v Hnp H.
  destruct v; cbn; auto. exfalso.
  destruct ch; try discriminate Hnp;
    first [ apply Mem.load_cast in H; cbn in H; discriminate H
          | apply Mem.load_type in H; cbn in H; exact H ].
Qed.

(* the fresh values: what the written cells hold afterwards *)
Variables (bm : block) (base : Z) (m' : mem).

Fixpoint updw (E : senv) (n : positive) (ws : wset) : senv :=
  match ws with
  | [] => E
  | (d, ch) :: ws' => updw (upd E n (Mem.load ch m' bm (base + d))) (Pos.succ n) ws'
  end.

Lemma updw_blk : forall ws E n, e_blk (updw E n ws) = e_blk E /\ e_base (updw E n ws) = e_base E.
Proof.
  induction ws as [| [d ch] ws IH]; intros E n; cbn [updw]; [auto |].
  destruct (IH (upd E n (Mem.load ch m' bm (base + d))) (Pos.succ n)) as [A B].
  rewrite A, B. split; reflexivity.
Qed.

Lemma updw_other : forall ws E n k, Plt k n -> e_rho (updw E n ws) k = e_rho E k.
Proof.
  induction ws as [| [d ch] ws IH]; intros E n k L; cbn [updw]; [reflexivity |].
  rewrite IH by (unfold Plt in *; lia).
  cbn. destruct (Pos.eq_dec k n); [subst; unfold Plt in L; lia | reflexivity].
Qed.

Lemma updw_Rx : forall ws E n, Rx E (updw E n ws) n.
Proof.
  induction ws as [| [d ch] ws IH]; intros E n; cbn [updw]; [apply Rx_refl |].
  eapply Rx_trans; [apply Rx_upd | apply IH | apply Ple_succ].
Qed.

Lemma updw_den : forall ws E n o0 rp d ch k,
  In (rp, o0 + d, ch, Sfresh k) (wentries rp o0 n ws) -> NoDup (map fst ws) ->
  e_rho (updw E n ws) k = Mem.load ch m' bm (base + d).
Proof.
  induction ws as [| [d1 ch1] ws IH]; intros E n o0 rp d ch k I ND; [destruct I |].
  cbn [wentries] in I. cbn [updw]. inversion ND as [| x l NI ND']; subst.
  destruct I as [E1 | I].
  - injection E1 as Ed <- <-. assert (d1 = d) by lia. subst d1.
    rewrite updw_other by (unfold Plt; lia). cbn. destruct (Pos.eq_dec n n); [reflexivity | congruence].
  - exact (IH _ _ _ _ _ _ _ I ND').
Qed.

Lemma updw_MM : forall ws E m g, MM E m g -> forallb (fun c => chunk_np (snd c)) ws = true ->
  MM (updw E (g_nx g) ws) m (freshn (length ws) g).
Proof.
  induction ws as [| [d ch] ws IH]; intros E m g M F; cbn [updw freshn length]; [exact M |].
  cbn [forallb snd] in F. apply andb_true_iff in F as [F1 F2].
  change (Pos.succ (g_nx g)) with (g_nx (gfresh g)).
  apply IH; [| exact F2].
  apply (MMg_fresh_o ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m g); [exact M |].
  intros v H. exact (np_load_old _ _ _ _ _ F1 H).
Qed.
End WR.

Section WRS.
Variable ge : genv.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).
Local Notation den := (den ge m0).

(* THE SOUNDNESS: any call with the footprint is described *)
Theorem c_wr_sound : forall ws args g cps E m vargs m' vres,
  c_wr nbase R0 ws args g = Some cps -> NoDup (map fst ws) ->
  MM E m g ->
  Forall2 (fun a v => den E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  (forall bm om rest, vargs = Vptr bm om :: rest -> fp bm om (wsizes ws) m m') ->
  vres = Vundef ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros ws args g cps E m vargs m' vres Hc ND MMh HF Hfp ->.
  unfold c_wr in Hc.
  destruct args as [| a1 rest]; [discriminate Hc |].
  destruct a1 as [ | rp op | | | | | | | | ]; try discriminate Hc.
  destruct (forallb (fun c => chunk_np (snd c)) ws) eqn:Fnp; [| discriminate Hc].
  destruct (sstores nbase R0 (freshn (length ws) g) (wentries rp (Ptrofs.unsigned op) (g_nx g) ws))
    as [g' |] eqn:S; [| discriminate Hc].
  injection Hc as <-.
  inversion HF as [| a v rest' vrest [Dp _] HF']; subst.
  cbn [SymExec2.den] in Dp. injection Dp as <-.
  set (bm := e_blk E rp) in *.
  set (om := Ptrofs.add (e_base E rp) op) in *.
  destruct (Hfp bm om vrest eq_refl) as (U & NBq & PP).
  set (base := Ptrofs.unsigned (e_base E rp) + Ptrofs.unsigned op).
  destruct (updw_blk bm base m' ws E (g_nx g)) as [EB EBs].
  set (E' := updw bm base m' E (g_nx g) ws) in *.
  assert (RX : Rx E E' (g_nx g)) by apply updw_Rx.
  assert (M1 : MM E' m (freshn (length ws) g))
    by (unfold E'; apply (updw_MM ge nbase R0 gtab kv m0 uf gp); [exact MMh | exact Fnp]).
  destruct (freshn_meta (length ws) g) as (Fsm & Fpc & Floc & Fcl & Fnx).
  (* each written cell, as an address *)
  assert (CB : forall d ch, In (d, ch) ws ->
            cbase om d = addr E' rp (Ptrofs.unsigned op + d)
            /\ 0 <= addr E' rp (Ptrofs.unsigned op + d)
            /\ addr E' rp (Ptrofs.unsigned op + d) + size_chunk ch <= Ptrofs.modulus).
  { intros d ch Iw.
    destruct (wentries_has rp (Ptrofs.unsigned op) ws (g_nx g) d ch Iw) as (k & Ik).
    pose proof (sstores_inb nbase R0 _ _ _ _ S Ik) as IB. cbn [skey] in IB.
    destruct (inb_abs ge nbase R0 gtab kv m0 uf gp _ _ _ _ _ _ M1 IB) as (O1 & A1 & A2).
    split; [| split; [exact A1 | exact A2]].
    unfold cbase, om. rewrite Ptrofs.add_assoc.
    unfold addr in *. rewrite EBs in *.
    pose proof (size_chunk_pos ch).
    pose proof (Ptrofs.unsigned_range op). pose proof (Ptrofs.unsigned_range (e_base E rp)).
    rewrite <- (Ptrofs.repr_unsigned (Ptrofs.add op (Ptrofs.repr d))).
    rewrite (uadd_small op d) by lia. rewrite uadd_small by lia. lia. }
  assert (HL : forall r o ch sv, In (r, o, ch, sv) (wentries rp (Ptrofs.unsigned op) (g_nx g) ws) ->
            sok nbase (g_nx (freshn (length ws) g)) sv
            /\ Mem.load ch m' (e_blk E' r) (addr E' r o) = den E' sv).
  { intros r o ch sv I.
    destruct (wentries_in rp _ ws (g_nx g) g _ eq_refl I) as (d & ch' & k & Eq & Iw & L1 & L2).
    injection Eq as -> -> <- ->. split; [cbn; split; [exact L2 | exact Logic.I] |].
    cbn [SymExec2.den]. rewrite EB. unfold addr. rewrite EBs.
    unfold E'. rewrite (updw_den bm base m' ws E (g_nx g) _ rp d ch k I ND).
    f_equal. unfold base. lia. }
  assert (HD : forall b z ch, Mem.valid_block m b ->
            (forall k, In k (wentries rp (Ptrofs.unsigned op) (g_nx g) ws) -> cell_disj E' (skey k) b z ch) ->
            Mem.load ch m' b z = Mem.load ch m b z).
  { intros b z ch V D. eapply Mem.load_unchanged_on_1; [exact U | exact V |].
    intros i Hi (Eb & d & s & Is & R).
    apply in_map_iff in Is as ([d' ch'] & Eds & Iw). cbn in Eds. injection Eds as <- <-.
    destruct (wentries_has rp (Ptrofs.unsigned op) ws (g_nx g) d' ch' Iw) as (k & Ik).
    pose proof (D _ Ik) as Dk. cbn [skey cell_disj] in Dk.
    destruct (CB _ _ Iw) as (C1 & _ & _). rewrite C1 in R. rewrite EB in Dk.
    subst b. destruct Dk as [N | [N | N]]; [exact (N eq_refl) | lia | lia]. }
  destruct (sstores_havoc nbase R0 ge gtab kv m0 uf gp gp_old E' m (freshn (length ws) g) _ g' m'
              M1 S HL HD ltac:(rewrite NBq; apply Ple_refl) ltac:(intros b o k p _; apply PP))
    as (M' & NXg & LCg & _).
  exists (g', Sconst Vundef). split; [left; reflexivity |].
  exists E'. split; [exact (Rx_Ext _ _ _ RX) |].
  split; [exact M' | split; [reflexivity | split; [cbn; split; [exact I | reflexivity] |]]].
  split; [rewrite NXg; exact Fnx | rewrite LCg; exact Floc].
Qed.
End WRS.

(* ---------------------------------------------------------------------- *)
(* update_air_without_turn, answered by its proved footprint              *)
(* ---------------------------------------------------------------------- *)

From SM64.Generated Require mario_actions_airborne.
From SM64.Proofs Require Import MarioModel.LinkedTwelve WMotRRequiresA.Unwired.FpuFloor Interp.LinkGenv.

Definition uawt_ws (ge : genv) : wset :=
  [(fo ge AIR._MarioState AIR._forwardVel, Mfloat32);
   (fo ge AIR._MarioState AIR._slideVelX, Mfloat32);
   (fo ge AIR._MarioState AIR._slideVelZ, Mfloat32);
   (fo ge AIR._MarioState AIR._vel, Mfloat32);
   (fo ge AIR._MarioState AIR._vel + 8, Mfloat32);
   (fo ge AIR._MarioState AIR._slideYaw, Mint16signed)].

Lemma uawt_ws_sizes : forall ge, wsizes (uawt_ws ge) = uawt_cells ge.
Proof. reflexivity. Qed.

Fixpoint znodup (l : list Z) : bool :=
  match l with [] => true | x :: l' => negb (existsb (Z.eqb x) l') && znodup l' end.

Lemma znodup_ok : forall l, znodup l = true -> NoDup l.
Proof.
  induction l as [| x l IH]; intros H; [constructor |].
  cbn in H. apply andb_true_iff in H as [H1 H2]. constructor; [| exact (IH H2)].
  intros I. apply negb_true_iff in H1.
  assert (existsb (Z.eqb x) l = true) by (apply existsb_exists; exists x; split; [exact I | apply Z.eqb_refl]).
  congruence.
Qed.

Lemma uawt_nodup12 : match ge12 with
  | Some ge => znodup (map fst (uawt_ws ge)) | None => false end = true.
Proof. vm_compute. reflexivity. Qed.

(* a one-parameter function is called with exactly one argument *)
Lemma funcall_one_arg : forall (ge : genv) f m v rest t m' vres x ty,
  fn_params f = [(x, ty)] ->
  eval_funcall function_entry2 ge m (Internal f) (v :: rest) t m' vres -> rest = [].
Proof.
  intros ge f m v rest t m' vres x ty Hp Hev. inv Hev.
  match goal with H : function_entry2 _ _ _ _ _ _ _ |- _ => inv H end.
  rewrite Hp in *. destruct rest; [reflexivity |].
  match goal with H : bind_parameter_temps _ _ _ = Some _ |- _ => cbn in H; discriminate H end.
Qed.

Lemma funcall_void : forall (ge : genv) f m vargs t m' vres,
  fn_return f = Tvoid ->
  eval_funcall function_entry2 ge m (Internal f) vargs t m' vres -> vres = Vundef.
Proof.
  intros ge f m vargs t m' vres Hr Hev. inv Hev.
  match goal with H : outcome_result_value _ _ _ _ |- _ => rewrite Hr in H; rename H into Ho end.
  destruct out as [| | | [[v ty] |]]; cbn in Ho; try contradiction; auto.
  destruct Ho as [N _]. congruence.
Qed.

Section UAWT.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Hypothesis Hsq : sqrtf_spec.
Local Notation G := (globalenv lp).
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).

(* THE CONTRACT for update_air_without_turn is sound *)
Theorem c_uawt_sound : forall args g cps E m vargs t m' vres,
  c_wr nbase R0 (uawt_ws G) args g = Some cps ->
  MMg G nbase R0 gtab kv m0 uf gp E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m (Internal AIR.f_update_air_without_turn) vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres Hc MMh HF Hev.
  pose proof uawt_nodup12 as ND. rewrite (ge12_ok lp H12) in ND.
  eapply (c_wr_sound G nbase R0 gtab kv m0 uf gp gp_old); [exact Hc | exact (znodup_ok _ ND) | exact MMh
    | exact HF | | exact (funcall_void _ AIR.f_update_air_without_turn _ _ _ _ _ eq_refl Hev)].
  intros bm om rest ->.
  rewrite (funcall_one_arg _ AIR.f_update_air_without_turn _ _ _ _ _ _ _ _ eq_refl Hev) in Hev.
  rewrite uawt_ws_sizes. exact (uawt_fp lp H12 Hsq _ _ _ _ _ _ Hev).
Qed.
End UAWT.
