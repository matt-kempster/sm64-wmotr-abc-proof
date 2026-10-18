(* ====================================================================== *)
(* FloorExec (unwired, GOAL 2): the GOAL-2 executor's contract for the     *)
(* real find_floor, PROVED SOUND against its generated Clight body         *)
(* (through FloorList.ff_value_contract).                                  *)
(*                                                                          *)
(* The contract (c_ff): the three static cells find_floor writes get some  *)
(* value, *pfloor gets NULL or a world surface (an Fworld fact), and the   *)
(* height is some value.                                                   *)
(*                                                                          *)
(* What it needs about the world is a consumer fact in the path condition, *)
(* Fuser kW [the consumer's regions], whose meaning (Wff) is a property of *)
(* the frame's entry memory m0:                                            *)
(*   - the three statics are writable;                                     *)
(*   - the surface partitions are well-formed lists through old blocks     *)
(*     outside the consumer's regions and the statics;                     *)
(*   - every surface on them is an old pointer outside the regions with    *)
(*     room for a Surface.                                                 *)
(* These are facts about the real game's memory: a later layer proves     *)
(* them as a frame invariant (no TRUST row).                               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs Require Import Interp.SymExec2 WMotRRequiresA.Unwired.FloorList.
From SM64.Proofs.WMotRRequiresA Require Import WMotRWorld.
Import ListNotations.

(* the consumer's region addresses, in R0's order *)
Definition wargs (R0 : list (positive * Z)) : list sval :=
  map (fun x => Sptr (fst x) Ptrofs.zero) R0.

Definition is_fact_W (kW : positive) (wa : list sval) (f : fact) : bool :=
  match f with
  | Fuser k a => Pos.eqb k kW && (if list_eq_dec sval_eq a wa then true else false)
  | _ => false
  end.

Definition fresh6 (g : gst) : gst := gfresh (gfresh (gfresh (gfresh (gfresh (gfresh g))))).

(* the type of a world surface is one of WMotR's (WMotRWorld, computed from
   the generated collision data) *)
Definition styp (m0 : mem) (b : block) (o : ptrofs) : Prop :=
  exists t, Mem.load Mint16signed m0 b (Ptrofs.unsigned o) = Some (Vint t)
    /\ In (Int.signed t) wmotr_surface_types.

(* "surface p's type is not k", in the exact shape the generated code tests
   it (p->type == k, an s16 field compared as int) *)
Definition tshort : type := Tint I16 Signed noattr.
Definition tint32 : type := Tint I32 Signed noattr.
Definition fty (k : Z) (p : sval) : fact :=
  Fbool (Sbinop Cop.Oeq (Swld p 0 Mint16signed) tshort (Sconst (Vint (Int.repr k))) tint32) tint32 false.
(* SURFACE_BURNING (1) and SURFACE_VERTICAL_WIND (56): not WMotR types *)
Definition ffacts (p : sval) : list fact := [fty 56 p; fty 1 p].

Lemma fty_holds : forall ge R0 m0 uf E p b o k, den ge m0 E p = Some (Vptr b o) ->
  styp m0 b o -> k = 1 \/ k = 56 -> fact_holds ge R0 m0 uf E (fty k p).
Proof.
  intros ge R0 m0 uf E p b o k D (t & L & IN) K. cbn [fact_holds fty den]. rewrite D.
  rewrite Ptrofs.add_zero, L.
  rewrite <- (Int.repr_signed t).
  rewrite wmotr_surface_types_value in IN.
  destruct IN as [X|[X|[X|[X|[X|[]]]]]]; rewrite <- X; destruct K as [-> | ->];
    eexists; split; reflexivity.
Qed.

(* THE CONTRACT.  The pointer argument must be a live local (find_floor's
   callers pass &floor, a local) and the world fact must be present. *)
Definition c_ff (nbase : positive) (R0 : list (positive * Z)) (rFI rMS rCL kW : positive)
    (szS : Z) : xcontract := fun args g =>
  match args with
  | [_; _; _; Sptr rp op] =>
      if existsb (Pos.eqb rp) (g_loc g) && existsb (is_fact_W kW (wargs R0)) (g_pc g) then
        let n0 := g_nx g in
        let n1 := Pos.succ n0 in let n2 := Pos.succ n1 in let n3 := Pos.succ n2 in
        let n4 := Pos.succ n3 in let n5 := Pos.succ n4 in
        match sstore nbase R0 (fresh6 g) rFI 0 Mint16signed (Sfresh n0) with
        | None => None
        | Some g1 =>
        match sstore nbase R0 g1 rMS 0 Mint16signed (Sfresh n1) with
        | None => None
        | Some g2 =>
        match sstore nbase R0 g2 rMS 2 Mint16signed (Sfresh n2) with
        | None => None
        | Some g3 =>
        match sstore nbase R0 g3 rCL 0 Mint16signed (Sfresh n3) with
        | None => None
        | Some g4 =>
        match sstore nbase R0 g4 rp (Ptrofs.unsigned op) Mint32 (Sconst (Vint Int.zero)),
              sstore nbase R0 g4 rp (Ptrofs.unsigned op) Mint32 (Sfresh n4) with
        | Some gN, Some gS =>
            Some [(gN, Sfresh n5);
                  (add_fact (add_fact (add_fact gS (Fworld (Sfresh n4) szS)) (fty 56 (Sfresh n4)))
                     (fty 1 (Sfresh n4)), Sfresh n5)]
        | _, _ => None
        end end end end end
      else None
  | _ => None
  end.

(* the statics the surface functions write, with their full sizes *)
Definition w_cells : list (ident * Z) :=
  [(surface_collision._gFindFloorIncludeSurfaceIntangible, 2);
   (surface_collision._gNumFindFloorMisses, 4); (surface_collision._gNumCalls, 6)].

(* region blocks named by the world fact's arguments *)
Definition rblk (vs : list (option val)) (b : block) : Prop :=
  exists o, In (Some (Vptr b o)) vs.

(* THE WORLD FACT's meaning (about the frame's entry memory m0) *)
Definition Wff (ge : genv) (m0 : mem) (gp : meminj) (szS : Z) (vs : list (option val)) : Prop :=
  (forall id sz, In (id, sz) w_cells ->
     exists b, Genv.find_symbol ge id = Some b /\ Mem.range_perm m0 b 0 sz Cur Writable)
  /\ (forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp ->
        Plt bp (Mem.nextblock m0) /\ ~ rblk vs bp /\ ~ is_static ge bp)
  /\ (forall hd, part_head ge m0 hd -> wf_list m0 (fun b => is_static ge b \/ rblk vs b) hd)
  /\ (forall hd s, part_head ge m0 hd -> on_list m0 hd s ->
        exists b o, s = Vptr b o /\ Plt b (Mem.nextblock m0)
          /\ Ptrofs.unsigned o + szS <= Ptrofs.modulus /\ ~ rblk vs b /\ gp b <> None)
  /\ (forall hd b o, part_head ge m0 hd -> on_list m0 hd (Vptr b o) -> styp m0 b o)
  /\ 0 <= szS.

(* ---- small facts ---- *)

Lemma ld16 : forall M b z v (gp : meminj), Mem.load Mint16signed M b z = Some v ->
  val_old gp v /\ Val.load_result Mint16signed v = v.
Proof.
  intros M b z v gp H. apply Mem.load_cast in H.
  destruct v; cbn in H |- *; try discriminate; split; auto; congruence.
Qed.

Lemma r0_size_in : forall R0 r sz, r0_size R0 r = Some sz -> In (r, sz) R0.
Proof.
  intros R0 r sz H. unfold r0_size in H.
  destruct (find _ R0) as [[r' sz']|] eqn:F; [| discriminate]. injection H as <-.
  pose proof (find_some _ _ F) as (I & E). cbn in E. apply Pos.eqb_eq in E. subst. exact I.
Qed.

Lemma upd_same : forall E k v, e_rho (upd E k v) k = v.
Proof. intros. cbn. destruct (Pos.eq_dec k k); congruence. Qed.
Lemma upd_other : forall E k k' v, k <> k' -> e_rho (upd E k' v) k = e_rho E k.
Proof. intros. cbn. destruct (Pos.eq_dec k k'); congruence. Qed.

(* a cell that avoids the five written cells *)
Definition dj (b : block) (z : Z) (ch : memory_chunk) (c : block * Z * memory_chunk) : Prop :=
  let '(b', z', ch') := c in b <> b' \/ z + size_chunk ch <= z' \/ z' + size_chunk ch' <= z.

Lemma load_store_dj : forall M M' ch' b' z' v b z ch,
  Mem.store ch' M b' z' v = Some M' -> dj b z ch (b', z', ch') ->
  Mem.load ch M' b z = Mem.load ch M b z.
Proof.
  intros M M' ch' b' z' v b z ch S D. eapply Mem.load_store_other; [exact S |].
  destruct D as [D | [D | D]]; [left; congruence | right; left; lia | right; right; lia].
Qed.

Lemma cd_dj : forall E r o ch b z ch',
  cell_disj E (r, o, ch) b z ch' -> dj b z ch' (e_blk E r, addr E r o, ch).
Proof. intros E r o ch b z ch' H. cbn in H |- *. destruct H as [H | [H | H]]; [left; congruence | right; right; lia | right; left; lia]. Qed.

Lemma sstore_keep : forall nbase R0 g r o ch sa g' e,
  sstore nbase R0 g r o ch sa = Some g' -> In e (g_sm g) -> ovl r o ch e = false -> In e (g_sm g').
Proof.
  intros nbase R0 g r o ch sa g' e S I N. unfold sstore in S.
  destruct (inb nbase R0 g r o ch); [| discriminate].
  destruct (forallb _ (g_sm g)); [| discriminate]. inv S. cbn [g_sm]. right.
  apply filter_In. split; [exact I | rewrite N; reflexivity].
Qed.

Lemma sstore_head : forall nbase R0 g r o ch sa g',
  sstore nbase R0 g r o ch sa = Some g' -> In (r, o, ch, sa) (g_sm g').
Proof.
  intros nbase R0 g r o ch sa g' S. unfold sstore in S.
  destruct (inb nbase R0 g r o ch); [| discriminate].
  destruct (forallb _ (g_sm g)); [| discriminate]. inv S. left. reflexivity.
Qed.

Lemma ovl_diff : forall r o ch r' o' ch' sv, r <> r' -> ovl r o ch (r', o', ch', sv) = false.
Proof. intros. unfold ovl. apply Pos.eqb_neq in H. rewrite H. reflexivity. Qed.

Section FE.
Variable ge : genv.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Let gp_plt {b} (H : gp b <> None) : Plt b (Mem.nextblock m0) :=
  match gp b as o return gp b = o -> Plt b (Mem.nextblock m0) with
  | Some x => fun G => gp_old b x G
  | None => fun G => False_ind _ (H G)
  end eq_refl.
Variables rFI rMS rCL kW : positive.
Variable szS : Z.

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).
Local Notation nb0 := (Mem.nextblock m0).
Local Notation den := (den ge m0).

Hypothesis HC : cenv_has ge.
Hypothesis Hpin : ffl_pinned ge.
Hypothesis HgFI : gfind gtab surface_collision._gFindFloorIncludeSurfaceIntangible = Some rFI.
Hypothesis HgMS : gfind gtab surface_collision._gNumFindFloorMisses = Some rMS.
Hypothesis HgCL : gfind gtab surface_collision._gNumCalls = Some rCL.
Hypothesis HU : forall vs, uf kW vs -> Wff ge m0 gp szS vs.

(* the consumer's regions are named by the world fact *)
Lemma r0_rblk : forall E r sz, r0_size R0 r = Some sz ->
  rblk (map (den E) (wargs R0)) (e_blk E r).
Proof.
  intros E r sz H. apply r0_size_in in H.
  exists (Ptrofs.add (e_base E r) Ptrofs.zero).
  change (Some (Vptr (e_blk E r) (Ptrofs.add (e_base E r) Ptrofs.zero)))
    with (den E (Sptr r Ptrofs.zero)).
  apply in_map. unfold wargs. exact (in_map (fun x => Sptr (fst x) Ptrofs.zero) _ _ H).
Qed.

(* an old block outside the regions reads as in m0 *)
Lemma ld_m0 : forall E m g b z ch, MM E m g -> Plt b nb0 ->
  ~ rblk (map (den E) (wargs R0)) b -> Mem.load ch m b z = Mem.load ch m0 b z.
Proof.
  intros E m g b z ch MMh OLD NR.
  pose proof MMh as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  apply FR; [exact OLD |]. intros [[[r o] ch'] sv] I. cbn [skey cell_disj]. left.
  destruct (ENT r o ch' sv I) as (IB & _).
  destruct (inb_spec _ _ _ _ _ _ IB) as [(_ & sz & S & _) | (_ & Il & _)].
  - intros Eb. apply NR. rewrite <- Eb. exact (r0_rblk E r sz S).
  - intros Eb. destruct (LOC r Il) as (_ & _ & _ & N & _). apply N. rewrite Eb. exact OLD.
Qed.

Section LISTS.
Variables (E : senv) (m : mem) (g : gst).
Hypothesis MMh : MM E m g.
Local Notation vs := (map (den E) (wargs R0)).

Lemma NXm : Ple nb0 (Mem.nextblock m).
Proof. destruct MMh as (_ & _ & _ & _ & _ & NX & _). exact NX. Qed.

Lemma wf_to_m : forall bpf hd, ~ Plt bpf nb0 ->
  wf_list m0 (fun b => is_static ge b \/ rblk vs b) hd ->
  wf_list m (fun b => is_static ge b \/ b = bpf) hd.
Proof.
  intros bpf hd Nb W. induction W as [| bn on nx Hv Hav Hld W IH]; [constructor |].
  apply wf_cons with nx.
  - unfold Mem.valid_block in *. eapply Plt_Ple_trans; [exact Hv | exact NXm].
  - intros [Hs | ->]; [apply Hav; left; exact Hs | contradiction].
  - cbn [Mem.loadv] in *. rewrite (ld_m0 E m g _ _ _ MMh Hv (fun H => Hav (or_intror H))). exact Hld.
  - exact IH.
Qed.

Lemma on_list_to_m0 : forall hd s,
  wf_list m0 (fun b => is_static ge b \/ rblk vs b) hd -> on_list m hd s -> on_list m0 hd s.
Proof.
  intros hd s W. induction W as [| bn on nx Hv Hav Hld W IH]; intros OL; inv OL.
  - apply ol_here. cbn [Mem.loadv] in *.
    rewrite <- (ld_m0 E m g _ _ _ MMh Hv (fun H => Hav (or_intror H))). assumption.
  - cbn [Mem.loadv] in *.
    match goal with Hn : Mem.load _ m _ _ = Some ?nx' |- _ =>
      rewrite (ld_m0 E m g _ _ _ MMh Hv (fun H => Hav (or_intror H))) in Hn;
      rewrite Hld in Hn; injection Hn as <- end.
    eapply ol_next; [exact Hld | apply IH; assumption].
Qed.

Lemma part_head_to_m0 : forall hd, Wff ge m0 gp szS vs -> part_head ge m hd -> part_head ge m0 hd.
Proof.
  intros hd (_ & WP & _) (id & bp & o & Hin & Hs & Hl).
  destruct (WP id bp Hin Hs) as (Old & NR & _).
  exists id, bp, o. split; [exact Hin | split; [exact Hs |]].
  cbn [Mem.loadv] in *. rewrite <- (ld_m0 E m g _ _ _ MMh Old NR). exact Hl.
Qed.
End LISTS.


(* the statics are old blocks (their perms at m0 make them valid) *)
Lemma statics_old : forall vs b, Wff ge m0 gp szS vs -> is_static ge b -> Plt b nb0.
Proof.
  intros vs b (WS & _) (id & Hin & Hs).
  assert (exists sz, In (id, sz) w_cells /\ 0 < sz) as (sz & Hc & Hp).
  { cbn in Hin. destruct Hin as [<- | [<- | [<- | []]]];
      [exists 2 | exists 4 | exists 6]; split; cbn; auto; lia. }
  destruct (WS id sz Hc) as (b' & Hs' & Hr). rewrite Hs in Hs'. injection Hs' as <-.
  apply (Mem.perm_valid_block m0 b 0 Cur Writable). apply Hr. lia.
Qed.

Ltac pos_ne := let HH := fresh in intro HH; repeat rewrite <- Pos.add_1_r in HH; lia.

(* THE SOUNDNESS of c_ff against the real find_floor *)
Theorem c_ff_sound : forall args g cps E m vargs t m' vres,
  c_ff nbase R0 rFI rMS rCL kW szS args g = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m (Internal surface_collision.f_find_floor) vargs t m' vres ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres Hc MMh HF Hev.
  unfold c_ff in Hc.
  destruct args as [|a1 [|a2 [|a3 [|a4 [|a5 l]]]]]; try discriminate Hc;
    [| destruct a4; discriminate Hc].
  destruct a4 as [ | rp op | | | | | | | | ]; try discriminate Hc.
  destruct (existsb (Pos.eqb rp) (g_loc g) && existsb (is_fact_W kW (wargs R0)) (g_pc g)) eqn:CK;
    [| discriminate Hc].
  apply andb_true_iff in CK as [CL CW].
  apply existsb_exists in CL as (rp' & Il & Erp). apply Pos.eqb_eq in Erp. subst rp'.
  apply existsb_exists in CW as (fW & IW & EW).
  destruct fW as [ | | | k wa]; try discriminate EW.
  apply andb_true_iff in EW as [Ek Ewa]. apply Pos.eqb_eq in Ek. subst k.
  destruct (list_eq_dec sval_eq wa (wargs R0)) as [-> | ]; [| discriminate Ewa].
  set (n0 := g_nx g) in *.
  set (n1 := Pos.succ n0) in *. set (n2 := Pos.succ n1) in *. set (n3 := Pos.succ n2) in *.
  set (n4 := Pos.succ n3) in *. set (n5 := Pos.succ n4) in *.
  destruct (sstore nbase R0 (fresh6 g) rFI 0 Mint16signed (Sfresh n0)) as [g1|] eqn:S1;
    [| discriminate Hc].
  destruct (sstore nbase R0 g1 rMS 0 Mint16signed (Sfresh n1)) as [g2|] eqn:S2; [| discriminate Hc].
  destruct (sstore nbase R0 g2 rMS 2 Mint16signed (Sfresh n2)) as [g3|] eqn:S3; [| discriminate Hc].
  destruct (sstore nbase R0 g3 rCL 0 Mint16signed (Sfresh n3)) as [g4|] eqn:S4; [| discriminate Hc].
  destruct (sstore nbase R0 g4 rp (Ptrofs.unsigned op) Mint32 (Sconst (Vint Int.zero)))
    as [gN|] eqn:S5N; [| discriminate Hc].
  destruct (sstore nbase R0 g4 rp (Ptrofs.unsigned op) Mint32 (Sfresh n4)) as [gS|] eqn:S5S;
    [| discriminate Hc].
  injection Hc as <-.
  (* the arguments *)
  inv HF. match goal with H : Forall2 _ _ _ |- _ => inv H end.
  match goal with H : Forall2 _ _ _ |- _ => inv H end.
  match goal with H : Forall2 _ _ _ |- _ => inv H end.
  match goal with H : Forall2 _ _ _ |- _ => inv H end.
  match goal with H : den E (Sptr rp op) = Some _ /\ _ |- _ => destruct H as (Dp & _) end.
  cbn [SymExec2.den] in Dp. injection Dp as <-.
  pose proof MMh as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  destruct (LOC rp Il) as (_ & _ & Hb0 & Hnew & Hvm).
  rewrite Hb0, Ptrofs.add_zero_l in Hev.
  set (bpf := e_blk E rp) in *.
  (* the world fact *)
  destruct (PC _ IW) as (_ & HW). cbn [fact_holds] in HW. apply HU in HW.
  set (vs := map (den E) (wargs R0)) in *.
  pose proof HW as (WS & WP & WL & WSurf & WTy & Wsz).
  (* the static blocks *)
  destruct EO as (_ & _ & _ & EG & _ & _).
  destruct (EG _ _ HgFI) as (_ & BFI & SFI).
  destruct (EG _ _ HgMS) as (_ & BMS & SMS).
  destruct (EG _ _ HgCL) as (_ & BCL & SCL).
  set (bFI := e_blk E rFI) in *. set (bMS := e_blk E rMS) in *. set (bCL := e_blk E rCL) in *.
  assert (WFI : Mem.range_perm m0 bFI 0 2 Cur Writable).
  { destruct (WS surface_collision._gFindFloorIncludeSurfaceIntangible 2 ltac:(cbn; auto)) as (b & Hs & Hr).
    rewrite SFI in Hs. injection Hs as <-. exact Hr. }
  assert (WMS : Mem.range_perm m0 bMS 0 4 Cur Writable).
  { destruct (WS surface_collision._gNumFindFloorMisses 4 ltac:(cbn; auto)) as (b & Hs & Hr).
    rewrite SMS in Hs. injection Hs as <-. exact Hr. }
  assert (WCL : Mem.range_perm m0 bCL 0 2 Cur Writable).
  { destruct (WS surface_collision._gNumCalls 6 ltac:(cbn; auto)) as (b & Hs & Hr).
    rewrite SCL in Hs. injection Hs as <-. intros i Hi. apply Hr. lia. }
  assert (OFI : Plt bFI nb0) by (eapply statics_old; [exact HW | exists surface_collision._gFindFloorIncludeSurfaceIntangible; split; [cbn; auto | exact SFI]]).
  assert (OMS : Plt bMS nb0) by (eapply statics_old; [exact HW | exists surface_collision._gNumFindFloorMisses; split; [cbn; auto | exact SMS]]).
  assert (OCL : Plt bCL nb0) by (eapply statics_old; [exact HW | exists surface_collision._gNumCalls; split; [cbn; auto | exact SCL]]).
  (* the memory-level contract *)
  set (avoid := fun b => is_static ge b \/ b = bpf).
  destruct (ff_value_contract ge avoid HC Hpin m _ _ _ bpf op t m' vres
              (or_intror eq_refl) Hvm
              ltac:(intros b Hs; split; [left; exact Hs |];
                    intros ->; exact (Hnew (statics_old _ _ HW Hs)))
              ltac:(intros id bp Hin Hs; destruct (WP id bp Hin Hs) as (Old & NR & NS);
                    split; [eapply Plt_Ple_trans; [exact Old | exact NX] |];
                    intros [H | ->]; [exact (NS H) | exact (Hnew Old)])
              ltac:(intros hd PH; apply (wf_to_m E m g MMh bpf hd Hnew);
                    apply WL; exact (part_head_to_m0 E m g MMh hd HW PH))
              Hev)
    as (fl & Hfl & Hld & (U & UP) & Hwr & (h & ->)).
  (* old blocks: valid in m, same perms in m, m0 and m' *)
  assert (Vm : forall b, Plt b nb0 -> Mem.valid_block m b)
    by (intros b Hb; eapply Plt_Ple_trans; [exact Hb | exact NX]).
  assert (RD : forall b lo hi, Plt b nb0 -> Mem.range_perm m0 b lo hi Cur Writable ->
            Mem.range_perm m' b lo hi Cur Readable /\ Mem.range_perm m b lo hi Cur Writable).
  { intros b lo hi Hb Hr. split; intros i Hi.
    - apply (UP b i Cur Readable (Vm b Hb)). apply (VP b i Cur Readable Hb).
      eapply Mem.perm_implies; [exact (Hr i Hi) | constructor].
    - apply (VP b i Cur Writable Hb). exact (Hr i Hi). }
  destruct (RD _ _ _ OFI WFI) as (RFI' & WFI').
  destruct (RD _ _ _ OMS WMS) as (RMS' & WMS').
  destruct (RD _ _ _ OCL WCL) as (RCL' & WCL').
  (* the values the statics hold in m' *)
  destruct (Mem.valid_access_load m' Mint16signed bFI 0) as (v1 & L1).
  { split; [intros i Hi; apply RFI'; cbn in Hi; lia | apply Z.divide_0_r]. }
  destruct (Mem.valid_access_load m' Mint16signed bMS 0) as (v2 & L2).
  { split; [intros i Hi; apply RMS'; cbn in Hi; lia | apply Z.divide_0_r]. }
  destruct (Mem.valid_access_load m' Mint16signed bMS 2) as (v3 & L3).
  { split; [intros i Hi; apply RMS'; cbn in Hi; lia | exists 1; reflexivity]. }
  destruct (Mem.valid_access_load m' Mint16signed bCL 0) as (v4 & L4).
  { split; [intros i Hi; apply RCL'; cbn in Hi; lia | apply Z.divide_0_r]. }
  destruct (ld16 _ _ _ _ gp L1) as (O1 & LR1).
  destruct (ld16 _ _ _ _ gp L2) as (O2 & LR2).
  destruct (ld16 _ _ _ _ gp L3) as (O3 & LR3).
  destruct (ld16 _ _ _ _ gp L4) as (O4 & LR4).
  (* the floor: NULL, or an old world surface *)
  assert (FLc : fl = Vint Int.zero \/
                exists bs os, fl = Vptr bs os /\ Plt bs nb0
                  /\ Ptrofs.unsigned os + szS <= Ptrofs.modulus /\ ~ rblk vs bs /\ gp bs <> None).
  { destruct Hfl as [-> | (hd & PH & OL)]; [left; reflexivity | right].
    pose proof (part_head_to_m0 E m g MMh hd HW PH) as PH0.
    exact (WSurf hd fl PH0 (on_list_to_m0 E m g MMh hd fl (WL hd PH0) OL)). }
  assert (FTy : forall bs os, fl = Vptr bs os -> styp m0 bs os).
  { intros bs os ->. destruct Hfl as [Hn | (hd & PH & OL)]; [discriminate |].
    pose proof (part_head_to_m0 E m g MMh hd HW PH) as PH0.
    exact (WTy hd bs os PH0 (on_list_to_m0 E m g MMh hd _ (WL hd PH0) OL)). }
  assert (Ofl : val_old gp fl) by (destruct FLc as [-> | (bs & os & -> & Hb & _ & _ & G)]; cbn; auto).
  assert (LRfl : Val.load_result Mint32 fl = fl)
    by (destruct FLc as [-> | (bs & os & -> & _)]; reflexivity).
  rewrite LRfl in Hld.
  (* the names *)
  set (E1 := upd E n0 (Some v1)). set (E2 := upd E1 n1 (Some v2)).
  set (E3 := upd E2 n2 (Some v3)). set (E4 := upd E3 n3 (Some v4)).
  set (E5 := upd E4 n4 (Some fl)). set (E6 := upd E5 n5 (Some (Vsingle h))).
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m g v1 MMh O1) as M1.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E1 m _ v2 M1 O2) as M2.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E2 m _ v3 M2 O3) as M3.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E3 m _ v4 M3 O4) as M4.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E4 m _ fl M4 Ofl) as M5.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E5 m _ (Vsingle h) M5 I) as M6.
  change (gfresh (gfresh (gfresh (gfresh (gfresh (gfresh g)))))) with (fresh6 g) in M6.
  assert (NX6 : g_nx (fresh6 g) = Pos.succ n5) by reflexivity.
  assert (RX : Rx E E6 n0).
  { unfold E6, E5, E4, E3, E2, E1.
    do 5 (eapply Rx_trans; [| apply Rx_upd | unfold Ple, n5, n4, n3, n2, n1; lia]).
    apply Rx_upd. }
  assert (Den : forall k v, e_rho E6 k = Some v -> den E6 (Sfresh k) = Some v) by (intros; exact H).
  assert (D1 : den E6 (Sfresh n0) = Some v1) by (apply Den; (unfold E6, E5, E4, E3, E2, E1; repeat (first [ rewrite upd_same | rewrite upd_other by (unfold n5, n4, n3, n2, n1; lia) ]); reflexivity)).
  assert (D2 : den E6 (Sfresh n1) = Some v2) by (apply Den; (unfold E6, E5, E4, E3, E2, E1; repeat (first [ rewrite upd_same | rewrite upd_other by (unfold n5, n4, n3, n2, n1; lia) ]); reflexivity)).
  assert (D3 : den E6 (Sfresh n2) = Some v3) by (apply Den; (unfold E6, E5, E4, E3, E2, E1; repeat (first [ rewrite upd_same | rewrite upd_other by (unfold n5, n4, n3, n2, n1; lia) ]); reflexivity)).
  assert (D4 : den E6 (Sfresh n3) = Some v4) by (apply Den; (unfold E6, E5, E4, E3, E2, E1; repeat (first [ rewrite upd_same | rewrite upd_other by (unfold n5, n4, n3, n2, n1; lia) ]); reflexivity)).
  assert (D5 : den E6 (Sfresh n4) = Some fl) by (apply Den; (unfold E6, E5, E4, E3, E2, E1; repeat (first [ rewrite upd_same | rewrite upd_other by (unfold n5, n4, n3, n2, n1; lia) ]); reflexivity)).
  assert (D6 : den E6 (Sfresh n5) = Some (Vsingle h)) by (apply Den; (unfold E6, E5, E4, E3, E2, E1; repeat (first [ rewrite upd_same | rewrite upd_other by (unfold n5, n4, n3, n2, n1; lia) ]); reflexivity)).
  assert (SOK : forall k, Plt k (Pos.succ n5) -> sok nbase (g_nx (fresh6 g)) (Sfresh k))
    by (intros k Hk; rewrite NX6; split; [exact Hk | exact I]).
  assert (A0 : forall r, e_base E r = Ptrofs.zero -> forall o, addr E6 r o = o).
  { intros r Hr o. rewrite (addr_Rx E E6 n0 r o RX). unfold addr. rewrite Hr. reflexivity. }
  assert (BK : forall r, e_blk E6 r = e_blk E r) by reflexivity.
  (* the stores that replay find_floor's writes on m *)
  assert (AC1 : Mem.valid_access m Mint16signed bFI 0 Writable)
    by (split; [intros i Hi; apply WFI'; cbn in Hi; lia | apply Z.divide_0_r]).
  destruct (Mem.valid_access_store m Mint16signed bFI 0 v1 AC1) as (m1 & ST1).
  assert (AC2 : Mem.valid_access m1 Mint16signed bMS 0 Writable).
  { eapply Mem.store_valid_access_1; [exact ST1 |].
    split; [intros i Hi; apply WMS'; cbn in Hi; lia | apply Z.divide_0_r]. }
  destruct (Mem.valid_access_store m1 Mint16signed bMS 0 v2 AC2) as (m2 & ST2).
  assert (AC3 : Mem.valid_access m2 Mint16signed bMS 2 Writable).
  { eapply Mem.store_valid_access_1; [exact ST2 |]. eapply Mem.store_valid_access_1; [exact ST1 |].
    split; [intros i Hi; apply WMS'; cbn in Hi; lia | exists 1; reflexivity]. }
  destruct (Mem.valid_access_store m2 Mint16signed bMS 2 v3 AC3) as (m3 & ST3).
  assert (AC4 : Mem.valid_access m3 Mint16signed bCL 0 Writable).
  { eapply Mem.store_valid_access_1; [exact ST3 |]. eapply Mem.store_valid_access_1; [exact ST2 |].
    eapply Mem.store_valid_access_1; [exact ST1 |].
    split; [intros i Hi; apply WCL'; cbn in Hi; lia | apply Z.divide_0_r]. }
  destruct (Mem.valid_access_store m3 Mint16signed bCL 0 v4 AC4) as (m4 & ST4).
  assert (AC5 : Mem.valid_access m4 Mint32 bpf (Ptrofs.unsigned op) Writable).
  { do 4 (eapply Mem.store_valid_access_1; [eassumption |]). exact Hwr. }
  destruct (Mem.valid_access_store m4 Mint32 bpf (Ptrofs.unsigned op) fl AC5) as (m5 & ST5).
  (* the executor's state follows them *)
  destruct (sstore_sound ge nbase R0 gtab kv m0 uf gp gp_old E6 m (fresh6 g) rFI 0 Mint16signed (Sfresh n0)
              v1 m1 g1 M6 S1 (SOK n0 ltac:(unfold Plt, n5, n4, n3, n2, n1; lia)) D1 LR1
              ltac:(rewrite A0 by exact BFI; exact ST1)) as (M1' & X1 & Y1 & Z1).
  destruct (sstore_sound ge nbase R0 gtab kv m0 uf gp gp_old E6 m1 g1 rMS 0 Mint16signed (Sfresh n1)
              v2 m2 g2 M1' S2 ltac:(rewrite X1; apply SOK; unfold Plt, n5, n4, n3, n2, n1; lia) D2 LR2
              ltac:(rewrite A0 by exact BMS; exact ST2)) as (M2' & X2 & Y2 & Z2).
  destruct (sstore_sound ge nbase R0 gtab kv m0 uf gp gp_old E6 m2 g2 rMS 2 Mint16signed (Sfresh n2)
              v3 m3 g3 M2' S3 ltac:(rewrite X2, X1; apply SOK; unfold Plt, n5, n4, n3, n2, n1; lia) D3 LR3
              ltac:(rewrite A0 by exact BMS; exact ST3)) as (M3' & X3 & Y3 & Z3).
  destruct (sstore_sound ge nbase R0 gtab kv m0 uf gp gp_old E6 m3 g3 rCL 0 Mint16signed (Sfresh n3)
              v4 m4 g4 M3' S4 ltac:(rewrite X3, X2, X1; apply SOK; unfold Plt, n5, n4, n3, n2, n1; lia) D4 LR4
              ltac:(rewrite A0 by exact BCL; exact ST4)) as (M4' & X4 & Y4 & Z4).
  (* region names and blocks are distinct *)
  assert (NFM : bFI <> bMS) by (eapply Genv.global_addresses_distinct; [| exact SFI | exact SMS]; idne).
  assert (NFC : bFI <> bCL) by (eapply Genv.global_addresses_distinct; [| exact SFI | exact SCL]; idne).
  assert (NMC : bMS <> bCL) by (eapply Genv.global_addresses_distinct; [| exact SMS | exact SCL]; idne).
  assert (NpF : bpf <> bFI) by (intros E'; rewrite E' in Hnew; exact (Hnew OFI)).
  assert (NpM : bpf <> bMS) by (intros E'; rewrite E' in Hnew; exact (Hnew OMS)).
  assert (NpC : bpf <> bCL) by (intros E'; rewrite E' in Hnew; exact (Hnew OCL)).
  assert (RFM : rFI <> rMS) by (intros ->; exact (NFM eq_refl)).
  assert (RFC : rFI <> rCL) by (intros ->; exact (NFC eq_refl)).
  assert (RMC : rMS <> rCL) by (intros ->; exact (NMC eq_refl)).
  assert (RpF : rp <> rFI) by (intros ->; exact (NpF eq_refl)).
  assert (RpM : rp <> rMS) by (intros ->; exact (NpM eq_refl)).
  assert (RpC : rp <> rCL) by (intros ->; exact (NpC eq_refl)).
  assert (LCg : forall gg, g_loc gg = g_loc g4 -> g_loc gg = g_loc g)
    by (intros gg H; rewrite H, Y4, Y3, Y2, Y1; reflexivity).
  pose proof MMh as ((A1 & _) & _).
  (* THE TAIL: m5 and m' agree on everything the final state describes *)
  assert (TAIL : forall sv5 g5 gF,
            sstore nbase R0 g4 rp (Ptrofs.unsigned op) Mint32 sv5 = Some g5 ->
            den E6 sv5 = Some fl ->
            MM E6 m5 gF -> g_sm gF = g_sm g5 -> g_loc gF = g_loc g4 ->
            MM E6 m' gF).
  { intros sv5 g5 gF S5 D5' MF SM LCF.
    (* a cell avoiding the five written cells reads the same in m' and m5 *)
    assert (KEY : forall b z ch, Mem.valid_block m b ->
              dj b z ch (bFI, 0, Mint16signed) -> dj b z ch (bMS, 0, Mint16signed) ->
              dj b z ch (bMS, 2, Mint16signed) -> dj b z ch (bCL, 0, Mint16signed) ->
              dj b z ch (bpf, Ptrofs.unsigned op, Mint32) ->
              Mem.load ch m' b z = Mem.load ch m5 b z).
    { intros b z ch Hv J1 J2 J3 J4 J5.
      rewrite (load_store_dj _ _ _ _ _ _ _ _ _ ST5 J5), (load_store_dj _ _ _ _ _ _ _ _ _ ST4 J4),
        (load_store_dj _ _ _ _ _ _ _ _ _ ST3 J3), (load_store_dj _ _ _ _ _ _ _ _ _ ST2 J2),
        (load_store_dj _ _ _ _ _ _ _ _ _ ST1 J1).
      eapply Mem.load_unchanged_on_1; [exact U | exact Hv |].
      intros i Hi. split; [exact Hv |].
      intros [(-> & Hi1 & Hi2) | (id & sz & Hin & Hs & Hi1 & Hi2)].
      - cbn in J5. destruct J5 as [J | [J | J]]; [congruence | lia | lia].
      - cbn in Hin. destruct Hin as [Eq | [Eq | [Eq | []]]]; inv Eq.
        + rewrite SFI in Hs. injection Hs as <-. cbn in J1. destruct J1 as [J | [J | J]]; [congruence | lia | lia].
        + rewrite SMS in Hs. injection Hs as <-. cbn in J2, J3.
          destruct J2 as [J | [J | J]]; [congruence | lia |].
          destruct J3 as [J' | [J' | J']]; [congruence | lia | lia].
        + rewrite SCL in Hs. injection Hs as <-. cbn in J4. destruct J4 as [J | [J | J]]; [congruence | lia | lia]. }
    pose proof MF as (_ & _ & ENTF & _).
    assert (IBF : forall gk r o ch sa gk', sstore nbase R0 gk r o ch sa = Some gk' ->
                    g_loc gk = g_loc g -> inb nbase R0 gF r o ch = true).
    { intros gk r o ch sa gk' Sk Lk. rewrite (inb_loc nbase R0 gk gF) by (rewrite LCF, Lk; apply LCg; reflexivity).
      exact (sstore_inb _ _ _ _ _ _ _ _ Sk). }
    assert (IB1 := IBF _ _ _ _ _ _ S1 eq_refl).
    assert (IB2 := IBF _ _ _ _ _ _ S2 ltac:(rewrite Y1; reflexivity)).
    assert (IB3 := IBF _ _ _ _ _ _ S3 ltac:(rewrite Y2, Y1; reflexivity)).
    assert (IB4 := IBF _ _ _ _ _ _ S4 ltac:(rewrite Y3, Y2, Y1; reflexivity)).
    assert (IB5 := IBF _ _ _ _ _ _ S5 ltac:(rewrite Y4, Y3, Y2, Y1; reflexivity)).
    (* a cell disjoint (in the executor's sense) from the five new keys *)
    assert (DJ : forall b z ch,
              cell_disj E6 (rFI, 0, Mint16signed) b z ch -> cell_disj E6 (rMS, 0, Mint16signed) b z ch ->
              cell_disj E6 (rMS, 2, Mint16signed) b z ch -> cell_disj E6 (rCL, 0, Mint16signed) b z ch ->
              cell_disj E6 (rp, Ptrofs.unsigned op, Mint32) b z ch ->
              Mem.valid_block m b -> Mem.load ch m' b z = Mem.load ch m5 b z).
    { intros b z ch C1 C2 C3 C4 C5 Hv. apply cd_dj in C1, C2, C3, C4, C5.
      rewrite BK, A0 in C1, C2, C3, C4, C5 by assumption.
      exact (KEY b z ch Hv C1 C2 C3 C4 C5). }
    assert (INN : forall r o ch sv, In (r, o, ch, sv) (g_sm gF) ->
              (r, o, ch, sv) = (rp, Ptrofs.unsigned op, Mint32, sv5)
              \/ (r, o, ch, sv) = (rCL, 0, Mint16signed, Sfresh n3)
              \/ (r, o, ch, sv) = (rMS, 2, Mint16signed, Sfresh n2)
              \/ (r, o, ch, sv) = (rMS, 0, Mint16signed, Sfresh n1)
              \/ (r, o, ch, sv) = (rFI, 0, Mint16signed, Sfresh n0)
              \/ (In (r, o, ch, sv) (g_sm g)
                  /\ ovl rp (Ptrofs.unsigned op) Mint32 (r, o, ch, sv) = false
                  /\ ovl rCL 0 Mint16signed (r, o, ch, sv) = false
                  /\ ovl rMS 2 Mint16signed (r, o, ch, sv) = false
                  /\ ovl rMS 0 Mint16signed (r, o, ch, sv) = false
                  /\ ovl rFI 0 Mint16signed (r, o, ch, sv) = false)).
    { intros r o ch sv I. rewrite SM in I.
      destruct (sstore_in _ _ _ _ _ _ _ _ _ S5 I) as [? | (I4 & N5)]; [auto |].
      destruct (sstore_in _ _ _ _ _ _ _ _ _ S4 I4) as [? | (I3 & N4)]; [auto |].
      destruct (sstore_in _ _ _ _ _ _ _ _ _ S3 I3) as [? | (I2 & N3)]; [auto 6 |].
      destruct (sstore_in _ _ _ _ _ _ _ _ _ S2 I2) as [? | (I1 & N2)]; [auto 7 |].
      destruct (sstore_in _ _ _ _ _ _ _ _ _ S1 I1) as [? | (I0 & N1)]; [auto 8 |].
      do 5 right. auto 7. }
    apply (MMg_transfer ge nbase R0 gtab kv m0 uf gp E6 m5 gF m' MF).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ ST5), (Mem.nextblock_store _ _ _ _ _ _ ST4),
        (Mem.nextblock_store _ _ _ _ _ _ ST3), (Mem.nextblock_store _ _ _ _ _ _ ST2),
        (Mem.nextblock_store _ _ _ _ _ _ ST1).
      exact (Mem.unchanged_on_nextblock _ _ _ U).
    - intros r o ch sv I. destruct (ENTF r o ch sv I) as (IBo & _ & L5). rewrite L5.
      destruct (INN r o ch sv I) as [Eq | [Eq | [Eq | [Eq | [Eq | (I0 & N5 & N4 & N3 & N2 & N1)]]]]];
        try (injection Eq as -> -> -> ->; rewrite BK, A0 by assumption).
      + rewrite D5'. cbn [Mem.loadv] in Hld. exact Hld.
      + rewrite D4. exact L4.
      + rewrite D3. exact L3.
      + rewrite D2. exact L2.
      + rewrite D1. exact L1.
      + rewrite <- L5. apply DJ.
        * apply (inb_disj ge nbase R0 gtab kv m0 uf gp gp_old E6 m5 gF _ _ _ _ _ _ MF IB1 IBo).
          apply ovl_false in N1. destruct N1 as [N | [N | N]]; [left; exact N | right; right; exact N | right; left; exact N].
        * apply (inb_disj ge nbase R0 gtab kv m0 uf gp gp_old E6 m5 gF _ _ _ _ _ _ MF IB2 IBo).
          apply ovl_false in N2. destruct N2 as [N | [N | N]]; [left; exact N | right; right; exact N | right; left; exact N].
        * apply (inb_disj ge nbase R0 gtab kv m0 uf gp gp_old E6 m5 gF _ _ _ _ _ _ MF IB3 IBo).
          apply ovl_false in N3. destruct N3 as [N | [N | N]]; [left; exact N | right; right; exact N | right; left; exact N].
        * apply (inb_disj ge nbase R0 gtab kv m0 uf gp gp_old E6 m5 gF _ _ _ _ _ _ MF IB4 IBo).
          apply ovl_false in N4. destruct N4 as [N | [N | N]]; [left; exact N | right; right; exact N | right; left; exact N].
        * apply (inb_disj ge nbase R0 gtab kv m0 uf gp gp_old E6 m5 gF _ _ _ _ _ _ MF IB5 IBo).
          apply ovl_false in N5. destruct N5 as [N | [N | N]]; [left; exact N | right; right; exact N | right; left; exact N].
        * destruct (ENT r o ch sv I0) as (IBg & _).
          destruct (inb_spec _ _ _ _ _ _ IBg) as [(Lr & _) | (_ & Il' & _)].
          -- apply Vm. exact (gp_plt (A1 r Lr)).
          -- destruct (LOC r Il') as (_ & _ & _ & _ & P). exact P.
    - intros b z ch OLD Dall. apply DJ; [| | | | | exact (Vm b OLD)].
      + apply (Dall (rFI, 0, Mint16signed, Sfresh n0)). rewrite SM.
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S5); [| apply ovl_diff; congruence].
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S4); [| apply ovl_diff; congruence].
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S3); [| apply ovl_diff; congruence].
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S2); [| apply ovl_diff; congruence].
        exact (sstore_head _ _ _ _ _ _ _ _ S1).
      + apply (Dall (rMS, 0, Mint16signed, Sfresh n1)). rewrite SM.
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S5); [| apply ovl_diff; congruence].
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S4); [| apply ovl_diff; congruence].
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S3); [| unfold ovl; rewrite Pos.eqb_refl; reflexivity].
        exact (sstore_head _ _ _ _ _ _ _ _ S2).
      + apply (Dall (rMS, 2, Mint16signed, Sfresh n2)). rewrite SM.
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S5); [| apply ovl_diff; congruence].
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S4); [| apply ovl_diff; congruence].
        exact (sstore_head _ _ _ _ _ _ _ _ S3).
      + apply (Dall (rCL, 0, Mint16signed, Sfresh n3)). rewrite SM.
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S5); [| apply ovl_diff; congruence].
        exact (sstore_head _ _ _ _ _ _ _ _ S4).
      + apply (Dall (rp, Ptrofs.unsigned op, Mint32, sv5)). rewrite SM.
        exact (sstore_head _ _ _ _ _ _ _ _ S5).
    - intros b o k p OLD. rewrite <- (UP b o k p (Vm b OLD)).
      split; intro HH.
      + do 5 (eapply Mem.perm_store_1; [eassumption |]). exact HH.
      + do 5 (eapply Mem.perm_store_2; [eassumption |]). exact HH. }
  assert (NXg4 : g_nx g4 = Pos.succ n5) by (rewrite X4, X3, X2, X1; exact NX6).
  assert (FIN : forall gF, MM E6 m' gF -> g_loc gF = g_loc g -> g_nx gF = Pos.succ n5 ->
            CM ge nbase R0 gtab kv m0 uf gp E n0 (g_loc g) m' (Vsingle h) (gF, Sfresh n5)).
  { intros gF MF LF NF. exists E6. split; [exact (Rx_Ext _ _ _ RX) |].
    split; [exact MF |]. split; [exact D6 |].
    split; [rewrite NF; split; [apply Pos.lt_succ_diag_r | exact I] |].
    split; [rewrite NF; unfold Ple, n5, n4, n3, n2, n1; lia | exact LF]. }
  destruct FLc as [Efl | (bs & os & Efl & Obs & Ros & NRbs & _)].
  - (* NULL: the first outcome *)
    exists (gN, Sfresh n5). split; [left; reflexivity |].
    rewrite Efl in ST5.
    destruct (sstore_sound ge nbase R0 gtab kv m0 uf gp gp_old E6 m4 g4 rp (Ptrofs.unsigned op) Mint32
                (Sconst (Vint Int.zero)) (Vint Int.zero) m5 gN M4' S5N
                (sok_const _ _ (Vint Int.zero) eq_refl) eq_refl eq_refl
                ltac:(rewrite BK, A0 by exact Hb0; exact ST5)) as (M5' & X5 & Y5 & _).
    apply FIN; [| rewrite Y5; apply LCg; reflexivity | rewrite X5; exact NXg4].
    eapply (TAIL (Sconst (Vint Int.zero)) gN gN S5N); [rewrite Efl; reflexivity | exact M5' | reflexivity | exact Y5].
  - (* a world surface: the second outcome *)
    exists (add_fact (add_fact (add_fact gS (Fworld (Sfresh n4) szS)) (fty 56 (Sfresh n4)))
              (fty 1 (Sfresh n4)), Sfresh n5). split; [right; left; reflexivity |].
    destruct (sstore_sound ge nbase R0 gtab kv m0 uf gp gp_old E6 m4 g4 rp (Ptrofs.unsigned op) Mint32
                (Sfresh n4) fl m5 gS M4' S5S
                ltac:(rewrite NXg4; split; [cbn [nlt]; unfold Plt, n5; lia | exact I]) D5 LRfl
                ltac:(rewrite BK, A0 by exact Hb0; exact ST5)) as (M5' & X5 & Y5 & _).
    assert (MA : MM E6 m5 (add_fact gS (Fworld (Sfresh n4) szS))).
    { apply MMg_add_fact; [exact M5' | cbn; rewrite X5, NXg4; unfold Plt, n5; lia |].
      cbn [fact_holds]. exists bs, os. split; [rewrite D5, Efl; reflexivity |].
      split; [exact Obs | split; [exact Wsz | split; [exact Ros |]]].
      intros r sz Hsz. left. rewrite BK. intros Eb. apply NRbs. rewrite <- Eb.
      exact (r0_rblk E r sz Hsz). }
    assert (DF : den E6 (Sfresh n4) = Some (Vptr bs os)) by (rewrite D5, Efl; reflexivity).
    assert (NF : forall gg, g_nx gg = g_nx gS -> fact_nlt (g_nx gg) (fty 56 (Sfresh n4)) /\
                   fact_nlt (g_nx gg) (fty 1 (Sfresh n4))).
    { intros gg Hgg. rewrite Hgg, X5, NXg4. cbn [fact_nlt fty nlt]. unfold Plt, n5. split; split; auto; lia. }
    assert (MA2 : MM E6 m5 (add_fact (add_fact (add_fact gS (Fworld (Sfresh n4) szS)) (fty 56 (Sfresh n4)))
                              (fty 1 (Sfresh n4)))).
    { apply MMg_add_fact; [apply MMg_add_fact; [exact MA | apply (NF _ eq_refl) |] | apply (NF _ eq_refl) |];
        apply (fty_holds _ _ _ _ _ _ bs os); auto; exact (FTy bs os Efl). }
    apply FIN; [| cbn; rewrite Y5; apply LCg; reflexivity | cbn; rewrite X5; exact NXg4].
    eapply (TAIL (Sfresh n4) gS); [exact S5S | exact D5 | exact MA2 | reflexivity | cbn; exact Y5].
Qed.

End FE.
