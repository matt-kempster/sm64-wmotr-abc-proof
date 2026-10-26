(* ====================================================================== *)
(* CeilExec (unwired, GOAL 2): the GOAL-2 executor's contract for the      *)
(* real find_ceil, PROVED SOUND against its generated Clight body          *)
(* (through CeilList.fc_value_contract).                                   *)
(*                                                                          *)
(* The contract (c_fc): the one static cell find_ceil writes               *)
(* (gNumCalls.ceil, bytes 2..4 of gNumCalls) gets some value, *pceil gets  *)
(* NULL or a world surface (an Fworld fact), and the height is some value. *)
(*                                                                          *)
(* It needs the same consumer world fact as FloorExec's c_ff,              *)
(* Fuser kW [the consumer's regions], whose meaning is FloorExec.Wff on    *)
(* the frame's entry memory (a frame invariant for a later layer to prove, *)
(* not a TRUST row).                                                       *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs Require Import Interp.SymExec2 WMotRRequiresA.FloorList
  WMotRRequiresA.CeilList WMotRRequiresA.FloorExec.
Import ListNotations.

Definition fresh3 (g : gst) : gst := gfresh (gfresh (gfresh g)).

(* THE CONTRACT.  The pointer argument must be a live local (find_ceil's
   callers pass &ceil, a local) and the world fact must be present. *)
Definition c_fc (nbase : positive) (R0 : list (positive * Z)) (rCL kW : positive)
    (szS : Z) : xcontract := fun args g =>
  match args with
  | [_; _; _; Sptr rp op] =>
      if existsb (Pos.eqb rp) (g_loc g) && existsb (is_fact_W kW (wargs R0)) (g_pc g) then
        let n0 := g_nx g in let n1 := Pos.succ n0 in let n2 := Pos.succ n1 in
        match sstore nbase R0 (fresh3 g) rCL 2 Mint16signed (Sfresh n0) with
        | None => None
        | Some g1 =>
        match sstore nbase R0 g1 rp (Ptrofs.unsigned op) Mint32 (Sconst (Vint Int.zero)),
              sstore nbase R0 g1 rp (Ptrofs.unsigned op) Mint32 (Sfresh n1) with
        | Some gN, Some gS =>
            Some [(gN, Sfresh n2); (add_fact gS (Fworld (Sfresh n1) szS), Sfresh n2)]
        | _, _ => None
        end end
      else None
  | _ => None
  end.

Lemma static_c_static : forall ge b, is_static_c ge b -> is_static ge b.
Proof.
  intros ge b (id & Hin & Hs). exists id. split; [| exact Hs].
  cbn in Hin |- *. destruct Hin as [<- | []]. auto.
Qed.

Section FCE.
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
Variables rCL kW : positive.
Variable szS : Z.

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).
Local Notation nb0 := (Mem.nextblock m0).
Local Notation den := (den ge m0).

Hypothesis HC : cenv_has ge.
Hypothesis Hpin : fcl_pinned ge.
Hypothesis HgCL : gfind gtab surface_collision._gNumCalls = Some rCL.
Hypothesis HU : forall vs, uf kW vs -> Wff ge m0 gp szS vs.

(* THE SOUNDNESS of c_fc against the real find_ceil *)
Theorem c_fc_sound : forall args g cps E m vargs t m' vres,
  c_fc nbase R0 rCL kW szS args g = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m (Internal surface_collision.f_find_ceil) vargs t m' vres ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres Hc MMh HF Hev.
  unfold c_fc in Hc.
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
  set (n0 := g_nx g) in *. set (n1 := Pos.succ n0) in *. set (n2 := Pos.succ n1) in *.
  destruct (sstore nbase R0 (fresh3 g) rCL 2 Mint16signed (Sfresh n0)) as [g1|] eqn:S1;
    [| discriminate Hc].
  destruct (sstore nbase R0 g1 rp (Ptrofs.unsigned op) Mint32 (Sconst (Vint Int.zero)))
    as [gN|] eqn:S5N; [| discriminate Hc].
  destruct (sstore nbase R0 g1 rp (Ptrofs.unsigned op) Mint32 (Sfresh n1)) as [gS|] eqn:S5S;
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
  pose proof HW as (WS & WP & WL & WSurf & _ & _ & Wsz).
  (* the static block *)
  destruct EO as (_ & _ & _ & EG & _ & _).
  destruct (EG _ _ HgCL) as (_ & BCL & SCL).
  set (bCL := e_blk E rCL) in *.
  assert (WCL : Mem.range_perm m0 bCL 2 4 Cur Writable).
  { destruct (WS surface_collision._gNumCalls 6 ltac:(cbn; auto)) as (b & Hs & Hr).
    rewrite SCL in Hs. injection Hs as <-. intros i Hi. apply Hr. lia. }
  assert (OCL : Plt bCL nb0) by (eapply statics_old; [exact HW | exists surface_collision._gNumCalls; split; [cbn; auto | exact SCL]]).
  (* the memory-level contract *)
  set (avoid := fun b => is_static ge b \/ b = bpf).
  destruct (fc_value_contract ge avoid HC Hpin m _ _ _ bpf op t m' vres
              (or_intror eq_refl) Hvm
              ltac:(intros b Hs; apply static_c_static in Hs; split; [left; exact Hs |];
                    intros ->; exact (Hnew (statics_old _ _ _ _ _ _ HW Hs)))
              ltac:(intros id bp Hin Hs; destruct (WP id bp Hin Hs) as (Old & NR & NS);
                    split; [eapply Plt_Ple_trans; [exact Old | exact NX] |];
                    intros [H | ->]; [exact (NS H) | exact (Hnew Old)])
              ltac:(intros hd PH; apply (wf_to_m ge nbase R0 gtab kv m0 uf gp E m g MMh bpf hd Hnew);
                    apply WL; exact (part_head_to_m0 ge nbase R0 gtab kv m0 uf gp szS E m g MMh hd HW PH))
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
  destruct (RD _ _ _ OCL WCL) as (RCL' & WCL').
  (* the value the static holds in m' *)
  destruct (Mem.valid_access_load m' Mint16signed bCL 2) as (v1 & L1).
  { split; [intros i Hi; apply RCL'; cbn in Hi; lia | exists 1; reflexivity]. }
  destruct (ld16 _ _ _ _ gp L1) as (O1 & LR1).
  (* the ceiling: NULL, or an old world surface *)
  assert (FLc : fl = Vint Int.zero \/
                exists bs os, fl = Vptr bs os /\ Plt bs nb0
                  /\ Ptrofs.unsigned os + szS <= Ptrofs.modulus /\ ~ rblk vs bs /\ gp bs <> None).
  { destruct Hfl as [-> | (hd & PH & OL)]; [left; reflexivity | right].
    pose proof (part_head_to_m0 ge nbase R0 gtab kv m0 uf gp szS E m g MMh hd HW PH) as PH0.
    exact (WSurf hd fl PH0 (on_list_to_m0 ge nbase R0 gtab kv m0 uf gp E m g MMh hd fl (WL hd PH0) OL)). }
  assert (Ofl : val_old gp fl) by (destruct FLc as [-> | (bs & os & -> & Hb & _ & _ & G)]; cbn; auto).
  assert (LRfl : Val.load_result Mint32 fl = fl)
    by (destruct FLc as [-> | (bs & os & -> & _)]; reflexivity).
  rewrite LRfl in Hld.
  (* the names *)
  set (E1 := upd E n0 (Some v1)). set (E2 := upd E1 n1 (Some fl)).
  set (E3 := upd E2 n2 (Some (Vsingle h))).
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m g v1 MMh O1) as M1.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E1 m _ fl M1 Ofl) as M2.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E2 m _ (Vsingle h) M2 I) as M3.
  change (gfresh (gfresh (gfresh g))) with (fresh3 g) in M3.
  assert (NX3 : g_nx (fresh3 g) = Pos.succ n2) by reflexivity.
  assert (RX : Rx E E3 n0).
  { unfold E3, E2, E1.
    do 2 (eapply Rx_trans; [| apply Rx_upd | unfold Ple, n2, n1; lia]).
    apply Rx_upd. }
  assert (Den : forall k v, e_rho E3 k = Some v -> den E3 (Sfresh k) = Some v) by (intros; exact H).
  assert (D1 : den E3 (Sfresh n0) = Some v1) by (apply Den; (unfold E3, E2, E1; repeat (first [ rewrite upd_same | rewrite upd_other by (unfold n2, n1; lia) ]); reflexivity)).
  assert (D2 : den E3 (Sfresh n1) = Some fl) by (apply Den; (unfold E3, E2, E1; repeat (first [ rewrite upd_same | rewrite upd_other by (unfold n2, n1; lia) ]); reflexivity)).
  assert (D3 : den E3 (Sfresh n2) = Some (Vsingle h)) by (apply Den; (unfold E3, E2, E1; repeat (first [ rewrite upd_same | rewrite upd_other by (unfold n2, n1; lia) ]); reflexivity)).
  assert (SOK : forall k, Plt k (Pos.succ n2) -> sok nbase (g_nx (fresh3 g)) (Sfresh k))
    by (intros k Hk; rewrite NX3; split; [exact Hk | exact I]).
  assert (A0 : forall r, e_base E r = Ptrofs.zero -> forall o, addr E3 r o = o).
  { intros r Hr o. rewrite (addr_Rx E E3 n0 r o RX). unfold addr. rewrite Hr. reflexivity. }
  assert (BK : forall r, e_blk E3 r = e_blk E r) by reflexivity.
  (* the stores that replay find_ceil's writes on m *)
  assert (AC1 : Mem.valid_access m Mint16signed bCL 2 Writable)
    by (split; [intros i Hi; apply WCL'; cbn in Hi; lia | exists 1; reflexivity]).
  destruct (Mem.valid_access_store m Mint16signed bCL 2 v1 AC1) as (m1 & ST1).
  assert (AC5 : Mem.valid_access m1 Mint32 bpf (Ptrofs.unsigned op) Writable).
  { eapply Mem.store_valid_access_1; [eassumption |]. exact Hwr. }
  destruct (Mem.valid_access_store m1 Mint32 bpf (Ptrofs.unsigned op) fl AC5) as (m5 & ST5).
  (* the executor's state follows them *)
  destruct (sstore_sound ge nbase R0 gtab kv m0 uf gp gp_old E3 m (fresh3 g) rCL 2 Mint16signed (Sfresh n0)
              v1 m1 g1 M3 S1 (SOK n0 ltac:(unfold Plt, n2, n1; lia)) D1 LR1
              ltac:(rewrite A0 by exact BCL; exact ST1)) as (M1' & X1 & Y1 & Z1).
  assert (NpC : bpf <> bCL) by (intros E'; rewrite E' in Hnew; exact (Hnew OCL)).
  assert (RpC : rp <> rCL) by (intros ->; exact (NpC eq_refl)).
  assert (LCg : forall gg, g_loc gg = g_loc g1 -> g_loc gg = g_loc g)
    by (intros gg H; rewrite H, Y1; reflexivity).
  pose proof MMh as ((A1 & _) & _).
  (* THE TAIL: m5 and m' agree on everything the final state describes *)
  assert (TAIL : forall sv5 g5 gF,
            sstore nbase R0 g1 rp (Ptrofs.unsigned op) Mint32 sv5 = Some g5 ->
            den E3 sv5 = Some fl ->
            MM E3 m5 gF -> g_sm gF = g_sm g5 -> g_loc gF = g_loc g1 ->
            MM E3 m' gF).
  { intros sv5 g5 gF S5 D5' MF SM LCF.
    (* a cell avoiding the two written cells reads the same in m' and m5 *)
    assert (KEY : forall b z ch, Mem.valid_block m b ->
              dj b z ch (bCL, 2, Mint16signed) ->
              dj b z ch (bpf, Ptrofs.unsigned op, Mint32) ->
              Mem.load ch m' b z = Mem.load ch m5 b z).
    { intros b z ch Hv J4 J5.
      rewrite (load_store_dj _ _ _ _ _ _ _ _ _ ST5 J5), (load_store_dj _ _ _ _ _ _ _ _ _ ST1 J4).
      eapply Mem.load_unchanged_on_1; [exact U | exact Hv |].
      intros i Hi. split; [exact Hv |].
      intros [(-> & Hi1 & Hi2) | (id & lo & hi & Hin & Hs & Hi1 & Hi2)].
      - cbn in J5. destruct J5 as [J | [J | J]]; [congruence | lia | lia].
      - cbn in Hin. destruct Hin as [Eq | []]; inv Eq.
        rewrite SCL in Hs. injection Hs as <-. cbn in J4. destruct J4 as [J | [J | J]]; [congruence | lia | lia]. }
    pose proof MF as (_ & _ & ENTF & _).
    assert (IBF : forall gk r o ch sa gk', sstore nbase R0 gk r o ch sa = Some gk' ->
                    g_loc gk = g_loc g -> inb nbase R0 gF r o ch = true).
    { intros gk r o ch sa gk' Sk Lk. rewrite (inb_loc nbase R0 gk gF) by (rewrite LCF, Lk; apply LCg; reflexivity).
      exact (sstore_inb _ _ _ _ _ _ _ _ Sk). }
    assert (IB1 := IBF _ _ _ _ _ _ S1 eq_refl).
    assert (IB5 := IBF _ _ _ _ _ _ S5 ltac:(rewrite Y1; reflexivity)).
    assert (DJ : forall b z ch,
              cell_disj E3 (rCL, 2, Mint16signed) b z ch ->
              cell_disj E3 (rp, Ptrofs.unsigned op, Mint32) b z ch ->
              Mem.valid_block m b -> Mem.load ch m' b z = Mem.load ch m5 b z).
    { intros b z ch C4 C5 Hv. apply cd_dj in C4, C5.
      rewrite BK, A0 in C4, C5 by assumption.
      exact (KEY b z ch Hv C4 C5). }
    assert (INN : forall r o ch sv, In (r, o, ch, sv) (g_sm gF) ->
              (r, o, ch, sv) = (rp, Ptrofs.unsigned op, Mint32, sv5)
              \/ (r, o, ch, sv) = (rCL, 2, Mint16signed, Sfresh n0)
              \/ (In (r, o, ch, sv) (g_sm g)
                  /\ ovl rp (Ptrofs.unsigned op) Mint32 (r, o, ch, sv) = false
                  /\ ovl rCL 2 Mint16signed (r, o, ch, sv) = false)).
    { intros r o ch sv I. rewrite SM in I.
      destruct (sstore_in _ _ _ _ _ _ _ _ _ S5 I) as [? | (I4 & N5)]; [auto |].
      destruct (sstore_in _ _ _ _ _ _ _ _ _ S1 I4) as [? | (I0 & N1)]; [auto |].
      do 2 right. auto. }
    apply (MMg_transfer ge nbase R0 gtab kv m0 uf gp E3 m5 gF m' MF).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ ST5), (Mem.nextblock_store _ _ _ _ _ _ ST1).
      exact (Mem.unchanged_on_nextblock _ _ _ U).
    - intros r o ch sv I. destruct (ENTF r o ch sv I) as (IBo & _ & L5). rewrite L5.
      destruct (INN r o ch sv I) as [Eq | [Eq | (I0 & N5 & N1)]];
        try (injection Eq as -> -> -> ->; rewrite BK, A0 by assumption).
      + rewrite D5'. cbn [Mem.loadv] in Hld. exact Hld.
      + rewrite D1. exact L1.
      + rewrite <- L5. apply DJ.
        * apply (inb_disj ge nbase R0 gtab kv m0 uf gp gp_old E3 m5 gF _ _ _ _ _ _ MF IB1 IBo).
          apply ovl_false in N1. destruct N1 as [N | [N | N]]; [left; exact N | right; right; exact N | right; left; exact N].
        * apply (inb_disj ge nbase R0 gtab kv m0 uf gp gp_old E3 m5 gF _ _ _ _ _ _ MF IB5 IBo).
          apply ovl_false in N5. destruct N5 as [N | [N | N]]; [left; exact N | right; right; exact N | right; left; exact N].
        * destruct (ENT r o ch sv I0) as (IBg & _).
          destruct (inb_spec _ _ _ _ _ _ IBg) as [(Lr & _) | (_ & Il' & _)].
          -- apply Vm. exact (gp_plt (A1 r Lr)).
          -- destruct (LOC r Il') as (_ & _ & _ & _ & P). exact P.
    - intros b z ch OLD Dall. apply DJ; [| | exact (Vm b OLD)].
      + apply (Dall (rCL, 2, Mint16signed, Sfresh n0)). rewrite SM.
        apply (sstore_keep _ _ _ _ _ _ _ _ _ S5); [| apply ovl_diff; congruence].
        exact (sstore_head _ _ _ _ _ _ _ _ S1).
      + apply (Dall (rp, Ptrofs.unsigned op, Mint32, sv5)). rewrite SM.
        exact (sstore_head _ _ _ _ _ _ _ _ S5).
    - intros b o k p OLD. rewrite <- (UP b o k p (Vm b OLD)).
      split; intro HH.
      + do 2 (eapply Mem.perm_store_1; [eassumption |]). exact HH.
      + do 2 (eapply Mem.perm_store_2; [eassumption |]). exact HH. }
  assert (NXg1 : g_nx g1 = Pos.succ n2) by (rewrite X1; exact NX3).
  assert (FIN : forall gF, MM E3 m' gF -> g_loc gF = g_loc g -> g_nx gF = Pos.succ n2 ->
            CM ge nbase R0 gtab kv m0 uf gp E n0 (g_loc g) m' (Vsingle h) (gF, Sfresh n2)).
  { intros gF MF LF NF. exists E3. split; [exact (Rx_Ext _ _ _ RX) |].
    split; [exact MF |]. split; [exact D3 |].
    split; [rewrite NF; split; [apply Pos.lt_succ_diag_r | exact I] |].
    split; [rewrite NF; unfold Ple, n2, n1; lia | exact LF]. }
  destruct FLc as [Efl | (bs & os & Efl & Obs & Ros & NRbs & _)].
  - (* NULL: the first outcome *)
    exists (gN, Sfresh n2). split; [left; reflexivity |].
    rewrite Efl in ST5.
    destruct (sstore_sound ge nbase R0 gtab kv m0 uf gp gp_old E3 m1 g1 rp (Ptrofs.unsigned op) Mint32
                (Sconst (Vint Int.zero)) (Vint Int.zero) m5 gN M1' S5N
                (sok_const _ _ (Vint Int.zero) eq_refl) eq_refl eq_refl
                ltac:(rewrite BK, A0 by exact Hb0; exact ST5)) as (M5' & X5 & Y5 & _).
    apply FIN; [| rewrite Y5; apply LCg; reflexivity | rewrite X5; exact NXg1].
    eapply (TAIL (Sconst (Vint Int.zero)) gN gN S5N); [rewrite Efl; reflexivity | exact M5' | reflexivity | exact Y5].
  - (* a world surface: the second outcome *)
    exists (add_fact gS (Fworld (Sfresh n1) szS), Sfresh n2). split; [right; left; reflexivity |].
    destruct (sstore_sound ge nbase R0 gtab kv m0 uf gp gp_old E3 m1 g1 rp (Ptrofs.unsigned op) Mint32
                (Sfresh n1) fl m5 gS M1' S5S
                ltac:(rewrite NXg1; split; [cbn [nlt]; unfold Plt, n2, n1; lia | exact I]) D2 LRfl
                ltac:(rewrite BK, A0 by exact Hb0; exact ST5)) as (M5' & X5 & Y5 & _).
    assert (MA : MM E3 m5 (add_fact gS (Fworld (Sfresh n1) szS))).
    { apply MMg_add_fact; [exact M5' | cbn; rewrite X5, NXg1; unfold Plt, n2, n1; lia |].
      cbn [fact_holds]. exists bs, os. split; [rewrite D2, Efl; reflexivity |].
      split; [exact Obs | split; [exact (Wff_sz _ _ _ _ _ HW) | split; [exact Ros |]]].
      intros r sz Hsz. left. rewrite BK. intros Eb. apply NRbs. rewrite <- Eb.
      exact (r0_rblk ge R0 m0 E r sz Hsz). }
    apply FIN; [| cbn; rewrite Y5; apply LCg; reflexivity | cbn; rewrite X5; exact NXg1].
    eapply (TAIL (Sfresh n1) gS); [exact S5S | exact D2 | exact MA | reflexivity | cbn; exact Y5].
Qed.

End FCE.
