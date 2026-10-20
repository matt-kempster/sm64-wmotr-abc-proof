(* ====================================================================== *)
(* AirSum (unwired, GOAL 2): perform_air_step as ONE summarized call.      *)
(*                                                                        *)
(* The walk of the real perform_air_step (AirRun) has 1644 outcomes, and  *)
(* a caller that continues after it (common_air_action_step) cannot carry *)
(* them all.  c_pas runs the same walk at the caller's state, classifies  *)
(* every outcome (AirMatch.outcome_ok), and then FORGETS the values of    *)
(* Phi's moving cells (pos[1], vel[1], floorHeight, gfx.pos[1]): they get *)
(* fresh names, and one fact records what the classification proved:      *)
(*                                                                        *)
(*   Fuser kM [cls; result; entry cells (7); action/state/timer; 4 names] *)
(*                                                                        *)
(* meaning: the cells went from the entry value c to the new value c1 by  *)
(* one HeightMoveCatalog RangedMove, and an attach class (cls 1 landing,  *)
(* 2 ledge grab) also says which height it snapped to.  The outcomes then *)
(* join to a handful.                                                     *)
(*                                                                        *)
(* Soundness (c_pas_sound) is sx_call_sound for the inner walk, AirMove's *)
(* class theorems for the fact, and a renaming lemma for the new names.  *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Cop Clight ClightBigstep.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight AirMatch AirMove WallExec AirWr.
Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* Fresh names for a list of cells                                        *)
(* ---------------------------------------------------------------------- *)

Fixpoint fents (ks : list (positive * Z * memory_chunk)) (n : positive) : list sentry :=
  match ks with
  | nil => nil
  | (r, o, ch) :: ks' => (r, o, ch, Sfresh n) :: fents ks' (Pos.succ n)
  end.

Definition sv_of (e : sentry) : sval := let '(_, _, _, v) := e in v.

Section RN.
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

Variable m : mem.

(* name n, n+1, ... the current values of the cells ks *)
Fixpoint updk (E : senv) (n : positive) (ks : list (positive * Z * memory_chunk)) : senv :=
  match ks with
  | nil => E
  | (r, o, ch) :: ks' => updk (upd E n (Mem.load ch m (e_blk E r) (addr E r o))) (Pos.succ n) ks'
  end.

Lemma updk_blk : forall ks E n, e_blk (updk E n ks) = e_blk E /\ e_base (updk E n ks) = e_base E.
Proof.
  induction ks as [| [[r o] ch] ks IH]; intros E n; cbn [updk]; [auto |].
  destruct (IH (upd E n (Mem.load ch m (e_blk E r) (addr E r o))) (Pos.succ n)) as [A B].
  rewrite A, B. split; reflexivity.
Qed.

Lemma updk_other : forall ks E n k, Plt k n -> e_rho (updk E n ks) k = e_rho E k.
Proof.
  induction ks as [| [[r o] ch] ks IH]; intros E n k L; cbn [updk]; [reflexivity |].
  rewrite IH by (unfold Plt in *; lia).
  cbn. destruct (Pos.eq_dec k n); [subst; unfold Plt in L; lia | reflexivity].
Qed.

Lemma updk_Rx : forall ks E n, Rx E (updk E n ks) n.
Proof.
  induction ks as [| [[r o] ch] ks IH]; intros E n; cbn [updk]; [apply Rx_refl |].
  eapply Rx_trans; [apply Rx_upd | apply IH | apply Ple_succ].
Qed.

Lemma updk_den : forall ks E n r o ch k, In (r, o, ch, Sfresh k) (fents ks n) ->
  e_rho (updk E n ks) k = Mem.load ch m (e_blk E r) (addr E r o).
Proof.
  induction ks as [| [[r1 o1] ch1] ks IH]; intros E n r o ch k I; [destruct I |].
  cbn [fents] in I. cbn [updk].
  destruct I as [E1 | I].
  - injection E1 as <- <- <- <-.
    rewrite updk_other by apply Plt_succ. cbn. destruct (Pos.eq_dec n n); [reflexivity | congruence].
  - rewrite (IH _ _ _ _ _ _ I).
    destruct (updk_blk ks (upd E n (Mem.load ch1 m (e_blk E r1) (addr E r1 o1))) (Pos.succ n)) as [_ _].
    reflexivity.
Qed.

Lemma fents_in : forall ks n e, In e (fents ks n) ->
  exists r o ch k, e = (r, o, ch, Sfresh k) /\ In (r, o, ch) ks /\ Ple n k
                   /\ Plt k (Pos.of_nat (Pos.to_nat n + length ks)).
Proof.
  induction ks as [| [[r o] ch] ks IH]; intros n e I; [destruct I |].
  destruct I as [<- | I].
  - exists r, o, ch, n. split; [reflexivity | split; [left; reflexivity | split; [apply Ple_refl |]]].
    unfold Plt. cbn [length]. lia.
  - destruct (IH (Pos.succ n) e I) as (r' & o' & ch' & k & -> & Ik & L1 & L2).
    exists r', o', ch', k. split; [reflexivity | split; [right; exact Ik | split]].
    + unfold Ple in *. lia.
    + unfold Plt in *. cbn [length]. rewrite Pos2Nat.inj_succ in L2. lia.
Qed.

Definition chunk_npk (k : positive * Z * memory_chunk) : bool := let '(_, _, ch) := k in chunk_np ch.

Lemma updk_MM : forall ks E g, MM E m g -> forallb chunk_npk ks = true ->
  MM (updk E (g_nx g) ks) m (freshn (length ks) g).
Proof.
  induction ks as [| [[r o] ch] ks IH]; intros E g M F; cbn [updk freshn length]; [exact M |].
  cbn [forallb chunk_npk] in F. apply andb_true_iff in F as [F1 F2].
  change (Pos.succ (g_nx g)) with (g_nx (gfresh g)).
  apply IH; [| exact F2].
  apply (MMg_fresh_o ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m g); [exact M |].
  intros v H. exact (np_load_old gp _ _ _ _ _ F1 H).
Qed.

Lemma freshn_nx_add : forall k g, g_nx (freshn k g) = Pos.of_nat (Pos.to_nat (g_nx g) + k).
Proof.
  induction k as [| k IH]; intros g; cbn [freshn].
  - rewrite Nat.add_0_r, Pos2Nat.id. reflexivity.
  - rewrite IH. cbn [gfresh g_nx]. rewrite Pos2Nat.inj_succ. f_equal. lia.
Qed.

(* RENAMING: the cells ks get fresh names for their current values; the
   memory is the same *)
Theorem rename_cells : forall ks E g g'',
  MM E m g -> forallb chunk_npk ks = true ->
  sstores nbase R0 (freshn (length ks) g) (fents ks (g_nx g)) = Some g'' ->
  MM (updk E (g_nx g) ks) m g'' /\ Rx E (updk E (g_nx g) ks) (g_nx g)
  /\ g_nx g'' = g_nx (freshn (length ks) g) /\ g_loc g'' = g_loc g /\ g_pc g'' = g_pc g.
Proof.
  intros ks E g g'' M F S.
  pose proof (updk_MM ks E g M F) as M1.
  destruct (updk_blk ks E (g_nx g)) as [EB EBs].
  destruct (sstores_havoc nbase R0 ge gtab kv m0 uf gp gp_old _ m _ _ g'' m M1 S) as (M2 & NX & LC & PC).
  - intros r o ch sv I. destruct (fents_in ks (g_nx g) _ I) as (r' & o' & ch' & k & Eq & Ik & L1 & L2).
    injection Eq as <- <- <- ->.
    split; [split; [cbn [nlt]; rewrite freshn_nx_add; exact L2 | exact Logic.I] |].
    cbn [den]. rewrite (updk_den ks E (g_nx g) r o ch k I). unfold addr. rewrite EB, EBs. reflexivity.
  - intros b z ch _ _. reflexivity.
  - apply Ple_refl.
  - intros; reflexivity.
  - destruct (freshn_meta (length ks) g) as (_ & PCf & LCf & _).
    split; [exact M2 | split; [apply updk_Rx | split; [exact NX | split; congruence]]].
Qed.
End RN.

(* ---------------------------------------------------------------------- *)
(* The abstraction of one classified outcome                              *)
(* ---------------------------------------------------------------------- *)

(* Phi's moving cells, renamed: pos[1], vel[1], floorHeight, gfx.pos[1] *)
Definition mkeys (rM rO : positive) : list (positive * Z * memory_chunk) :=
  [(rM, oY, Mfloat32); (rM, oV, Mfloat32); (rM, oF, Mfloat32); (rO, oG, Mfloat32)].

(* all seven cells, in cells order *)
Definition pkeys (rM rO : positive) : list (positive * Z * memory_chunk) :=
  [(rM, oA, Mint32); (rM, oS, Mint16unsigned); (rM, oT, Mint16unsigned)] ++ mkeys rM rO.

Section ABS.
Variables (nbase : positive) (R0 : list (positive * Z)) (kv : list (positive * Z * memory_chunk * sval)).
Variables (rM rO kH kM : positive).

(* the class: 1 a landing, 2 a ledge grab at pos[1] = floorHeight, 0 any
   other classified outcome; None for an unclassified one *)
Definition cls_of (g : gst) : option int :=
  let LD := sload nbase R0 kv g in
  let IC := init_cell kv in
  if cells_ok LD (g_pc g) rM rO kH && land_ok LD IC (g_pc g) rM rO kH then Some Int.one
  else if cells_ok LD (g_pc g) rM rO kH && ledge_ok LD IC (g_pc g) rM rO kH
          && match LD rM oF Mfloat32, LD rM oY Mfloat32 with
             | Some a, Some b => sveqb a b | _, _ => false end
  then Some (Int.repr 2)
  else if outcome_ok LD IC (g_pc g) rM rO kH then Some Int.zero
  else None.

Definition ic_of (k : positive * Z * memory_chunk) : sval := let '(r, o, ch) := k in init_cell kv r o ch.

Definition absM (c : cpath) : option cpath :=
  let '(g', r) := c in
  match cls_of g', sload nbase R0 kv g' rM oA Mint32, sload nbase R0 kv g' rM oS Mint16unsigned,
        sload nbase R0 kv g' rM oT Mint16unsigned with
  | Some cl, Some sa, Some ss, Some st =>
      let n := g_nx g' in
      match sstores nbase R0 (freshn 4 g') (fents (mkeys rM rO) n) with
      | Some g'' =>
          Some (add_fact g'' (Fuser kM (Sfresh n :: Sconst (Vint cl) :: r :: map ic_of (pkeys rM rO)
                                        ++ [sa; ss; st] ++ map sv_of (fents (mkeys rM rO) n))), r)
      | None => None
      end
  | _, _, _, _ => None
  end.
End ABS.

(* ---------------------------------------------------------------------- *)
(* The fact's meaning                                                     *)
(* ---------------------------------------------------------------------- *)

Definition cvals (c : cells) : list val :=
  [Vint (c_action c); Vint (c_state c); Vint (c_timer c); Vsingle (c_posy c); Vsingle (c_vely c);
   Vsingle (c_floorh c); Vsingle (c_gfxy c)].

(* from the entry cells c, the air step made the cells c1 by one RangedMove;
   a landing or ledge grab also says where it attached *)
Definition PMc (cl : int) (c c1 : cells) : Prop :=
  RM' c c1 /\ (cl <> Int.zero -> AttachInfo c c1)
  /\ (cl = Int.repr 2 -> AttachOK wmotr_floor wmotr_pole wmotr_cannon c (R2 (c_floorh c1))).

Definition PMv (cl : int) (c c1 : cells) : Prop :=
  c_action c = ACT_FREEFALL -> budget_ok c ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)) -> PMc cl c c1.

(* the fact's arguments: whenever the entry cells are cells c of a
   freefall state in budget (with a fresh floor), the arguments are the
   class, the result, c, and the cells c1 the step made, with PMc *)
Definition MV (vs : list (option val)) : Prop :=
  forall c, firstn 7 (skipn 3 vs) = map Some (cvals c) ->
  c_action c = ACT_FREEFALL -> budget_ok c ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)) ->
  exists cl rv c1, vs = map Some (Vsingle (c_posy c1) :: Vint cl :: rv :: cvals c ++ cvals c1)
                   /\ PMc cl c c1.

(* ---------------------------------------------------------------------- *)
(* Each class proves PMv (AirMove)                                        *)
(* ---------------------------------------------------------------------- *)

Section PMV.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (E : senv) (m : mem) (g : gst) (rM rO kH : positive).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HUH : forall vs, uf kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at ge m0) (ycast yv) h /\ Hit_at ge m0 h.
Hypothesis HbM : e_base E rM = Ptrofs.zero.
Hypothesis FD : floor_data ge m0.
Local Notation bm := (e_blk E rM).

(* the cells c, read at memory m1 through the regions (gfx.pos[1] at Mario's
   object region) *)
Definition at_cells (m1 : mem) (c : cells) : Prop :=
  Mem.load Mint32 m1 bm oA = Some (Vint (c_action c))
  /\ Mem.load Mint16unsigned m1 bm oS = Some (Vint (c_state c))
  /\ Mem.load Mint16unsigned m1 bm oT = Some (Vint (c_timer c))
  /\ Mem.load Mfloat32 m1 bm oY = Some (Vsingle (c_posy c))
  /\ Mem.load Mfloat32 m1 bm oV = Some (Vsingle (c_vely c))
  /\ Mem.load Mfloat32 m1 bm oF = Some (Vsingle (c_floorh c))
  /\ Mem.load Mfloat32 m1 (e_blk E rO) (addr E rO oG) = Some (Vsingle (c_gfxy c)).

Lemma cells_unique : forall c' c1,
  Mem.load Mint32 m bm oMO = Some (Vptr (e_blk E rO) (e_base E rO)) ->
  read_cells bm m c' -> at_cells m c1 -> c' = c1.
Proof.
  intros c' c1 LMO (A & S & T & Y & V & F & bo & oo & LO & GY) (A1 & S1 & T1 & Y1 & V1 & F1 & G1).
  change Mptr with Mint32 in LO. change OFS_MARIOOBJ with oMO in LO. rewrite LMO in LO.
  injection LO as <- <-. unfold addr in G1. change OFS_GFXY with oG in GY.
  change OFS_ACTION with oA in A. change OFS_ASTATE with oS in S. change OFS_ATIMER with oT in T.
  change OFS_POSY with oY in Y. change OFS_VELY with oV in V. change OFS_FLOORH with oF in F.
  rewrite A1 in A. rewrite S1 in S. rewrite T1 in T. rewrite Y1 in Y. rewrite V1 in V.
  rewrite F1 in F. rewrite G1 in GY.
  injection A as A. injection S as S. injection T as T. injection Y as Y. injection V as V.
  injection F as F. injection GY as GY.
  destruct c', c1. cbn in *. subst. reflexivity.
Qed.

Lemma ld_eq_load : forall a b, sload nbase R0 kv g rM oF Mfloat32 = Some a ->
  sload nbase R0 kv g rM oY Mfloat32 = Some b -> sveqb a b = true ->
  Mem.load Mfloat32 m bm oF = Mem.load Mfloat32 m bm oY.
Proof.
  intros a b La Lb Q. unfold sveqb in Q. destruct (sval_eq a b) as [<- |]; [| discriminate].
  rewrite <- (addr_M E rM HbM oF).
  rewrite <- (addr_M E rM HbM oY).
  rewrite (ld_sound ge nbase R0 gtab kv m0 uf gp gp_old E m g MM _ _ _ _ La).
  rewrite (ld_sound ge nbase R0 gtab kv m0 uf gp gp_old E m g MM _ _ _ _ Lb). reflexivity.
Qed.

Theorem pmv_of : forall cl c c1, cls_of nbase R0 kv rM rO kH g = Some cl ->
  Mem.load Mint32 m0 bm oA = Some (Vint (c_action c)) ->
  Mem.load Mint16unsigned m0 bm oS = Some (Vint (c_state c)) ->
  Mem.load Mint16unsigned m0 bm oT = Some (Vint (c_timer c)) ->
  Mem.load Mfloat32 m0 bm oY = Some (Vsingle (c_posy c)) ->
  Mem.load Mfloat32 m0 bm oV = Some (Vsingle (c_vely c)) ->
  Mem.load Mfloat32 m0 bm oF = Some (Vsingle (c_floorh c)) ->
  at_cells m c1 -> PMv cl c c1.
Proof.
  intros cl c c1 CL HA HS HT HY HV HF AC Hact Hb FRO.
  unfold cls_of in CL.
  destruct (cells_ok (sload nbase R0 kv g) (g_pc g) rM rO kH) eqn:CO.
  2:{ unfold outcome_ok in CL. rewrite CO in CL. discriminate CL. }
  pose proof (proj1 (cells_sound ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM CO)) as LMO.
  cbn [andb] in CL.
  destruct (land_ok (sload nbase R0 kv g) (init_cell kv) (g_pc g) rM rO kH) eqn:LO.
  - injection CL as <-.
    destruct (land_move ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM c
                HA HS HT HY HV HF Hb Hact FD FRO CO LO) as (c' & RC & M & AI).
    rewrite (cells_unique c' c1 LMO RC AC) in M, AI.
    split; [exact M | split; [intros _; exact AI | intros E2; exfalso]].
    apply (f_equal Int.unsigned) in E2. vm_compute in E2. discriminate E2.
  - destruct (ledge_ok (sload nbase R0 kv g) (init_cell kv) (g_pc g) rM rO kH) eqn:LE.
    + destruct (ledge_move ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM c
                  HA HS HT HY HV HF Hb Hact FD CO LE) as (c' & RC & M & AI & AO).
      rewrite (cells_unique c' c1 LMO RC AC) in M, AI, AO.
      destruct (sload nbase R0 kv g rM oF Mfloat32) as [a|] eqn:La;
        [| destruct (outcome_ok _ _ _ _ _ _) in CL; [injection CL as <- | discriminate CL];
           split; [exact M | split; [intros N; exfalso; exact (N eq_refl) | intros E2; exfalso]];
           apply (f_equal Int.unsigned) in E2; vm_compute in E2; discriminate E2].
      destruct (sload nbase R0 kv g rM oY Mfloat32) as [b|] eqn:Lb;
        [| destruct (outcome_ok _ _ _ _ _ _) in CL; [injection CL as <- | discriminate CL];
           split; [exact M | split; [intros N; exfalso; exact (N eq_refl) | intros E2; exfalso]];
           apply (f_equal Int.unsigned) in E2; vm_compute in E2; discriminate E2].
      destruct (sveqb a b) eqn:Q.
      * injection CL as <-.
        split; [exact M | split; [intros _; exact AI | intros _; exact (AO (ld_eq_load a b La Lb Q))]].
      * destruct (outcome_ok _ _ _ _ _ _) in CL; [injection CL as <- | discriminate CL].
        split; [exact M | split; [intros N; exfalso; exact (N eq_refl) | intros E2; exfalso]].
        apply (f_equal Int.unsigned) in E2. vm_compute in E2. discriminate E2.
    + destruct (outcome_ok (sload nbase R0 kv g) (init_cell kv) (g_pc g) rM rO kH) eqn:OK;
        [injection CL as <- | discriminate CL].
      destruct (outcome_move ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM c
                  HA HS HT HY HV HF Hb Hact FD FRO OK) as (c' & RC & M).
      rewrite (cells_unique c' c1 LMO RC AC) in M.
      split; [exact M | split; [intros N; exfalso; exact (N eq_refl) | intros E2; exfalso]].
      apply (f_equal Int.unsigned) in E2. vm_compute in E2. discriminate E2.
Qed.

Lemma cls_outcome : forall cl, cls_of nbase R0 kv rM rO kH g = Some cl ->
  outcome_ok (sload nbase R0 kv g) (init_cell kv) (g_pc g) rM rO kH = true.
Proof.
  intros cl CL. unfold cls_of, outcome_ok in CL. unfold outcome_ok.
  destruct (cells_ok (sload nbase R0 kv g) (g_pc g) rM rO kH); [| discriminate CL].
  cbn [andb] in *.
  destruct (aclass_of (sload nbase R0 kv g) (init_cell kv) (g_pc g) rM rO kH); [reflexivity |].
  destruct (land_ok (sload nbase R0 kv g) (init_cell kv) (g_pc g) rM rO kH); [reflexivity |].
  destruct (ledge_ok (sload nbase R0 kv g) (init_cell kv) (g_pc g) rM rO kH); [reflexivity |].
  cbn [andb] in CL. discriminate CL.
Qed.

(* the step's cells exist and are read through the regions *)
Theorem step_cells : forall cl c, cls_of nbase R0 kv rM rO kH g = Some cl ->
  Mem.load Mint32 m0 bm oA = Some (Vint (c_action c)) ->
  Mem.load Mint16unsigned m0 bm oS = Some (Vint (c_state c)) ->
  Mem.load Mint16unsigned m0 bm oT = Some (Vint (c_timer c)) ->
  Mem.load Mfloat32 m0 bm oY = Some (Vsingle (c_posy c)) ->
  Mem.load Mfloat32 m0 bm oV = Some (Vsingle (c_vely c)) ->
  Mem.load Mfloat32 m0 bm oF = Some (Vsingle (c_floorh c)) ->
  c_action c = ACT_FREEFALL -> budget_ok c ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)) ->
  exists c1, at_cells m c1.
Proof.
  intros cl c CL HA HS HT HY HV HF Hact Hb FRO.
  pose proof (cls_outcome cl CL) as OK.
  pose proof OK as OK'. unfold outcome_ok in OK'. apply andb_true_iff in OK' as [CO _].
  pose proof (proj1 (cells_sound ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM CO)) as LMO.
  destruct (outcome_move ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM c
              HA HS HT HY HV HF Hb Hact FD FRO OK) as (c' & RC & _).
  exists c'. destruct RC as (A & S & T & Y & V & F & bo & oo & LO & GY).
  change Mptr with Mint32 in LO. change OFS_MARIOOBJ with oMO in LO. rewrite LMO in LO.
  injection LO as <- <-.
  unfold at_cells, addr. repeat split; assumption.
Qed.
End PMV.

(* ---------------------------------------------------------------------- *)
(* The abstraction is sound                                               *)
(* ---------------------------------------------------------------------- *)

Section ABSS.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (rM rO kH kM : positive) (idM : ident).
(* Mario's state region is a global's (so its base is 0) *)
Hypothesis Hgt : gfind gtab idM = Some rM.
Hypothesis HrO : Plt rO nbase.
Hypothesis HUH : forall vs, uf kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at ge m0) (ycast yv) h /\ Hit_at ge m0 h.
Hypothesis HUM : forall vs, MV vs -> uf kM vs.
Hypothesis FD : floor_data ge m0.

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).
Local Notation CMx := (CM ge nbase R0 gtab kv m0 uf gp).
Local Notation den := (SymExec2.den ge m0).

Lemma nlt_up : forall a n n', nlt n a -> Ple n n' -> nlt n' a.
Proof. intros. exact (nlt_mono nbase (fun _ => None) (fun _ => false) uf a n n' H H0). Qed.

Lemma sok_up : forall a n n', sok nbase n a -> Ple n n' -> nlt n' a.
Proof. intros a n n' [H _] L. exact (nlt_up a n n' H L). Qed.

Theorem absM_sound : forall E0 n0 gl m' v c c',
  absM nbase R0 kv rM rO kH kM c = Some c' -> CMx E0 n0 gl m' v c -> CMx E0 n0 gl m' v c'.
Proof.
  intros E0 n0 gl m' v [g' r] c' H (E' & X & MM' & D & S & L & G).
  unfold absM in H.
  destruct (cls_of nbase R0 kv rM rO kH g') as [cl|] eqn:CL; [| discriminate H].
  destruct (sload nbase R0 kv g' rM oA Mint32) as [sa|] eqn:La; [| discriminate H].
  destruct (sload nbase R0 kv g' rM oS Mint16unsigned) as [ss|] eqn:Ls; [| discriminate H].
  destruct (sload nbase R0 kv g' rM oT Mint16unsigned) as [st|] eqn:Lt; [| discriminate H].
  destruct (sstores nbase R0 (freshn 4 g') (fents (mkeys rM rO) (g_nx g'))) as [g''|] eqn:SS;
    [| discriminate H].
  injection H as <-.
  pose proof MM' as (EO & NBl & _).
  pose proof EO as (_ & _ & _ & GT & _).
  destruct (GT idM rM Hgt) as (PrM & HbM & _).
  destruct (rename_cells ge nbase R0 gtab kv m0 uf gp gp_old m' (mkeys rM rO) E' g' g'' MM' eq_refl SS)
    as (M2 & RX & NX & LC & PC).
  set (n := g_nx g') in *.
  set (E'' := updk m' E' n (mkeys rM rO)) in *.
  destruct (updk_blk m' (mkeys rM rO) E' n) as [EB EBs]. fold E'' in EB, EBs.
  pose proof M2 as (EO'' & _).
  assert (NN : Ple n (g_nx g'')).
  { rewrite NX. destruct (freshn_meta 4 g') as (_ & _ & _ & _ & P). exact P. }
  assert (NX4 : g_nx g'' = Pos.of_nat (Pos.to_nat n + 4)) by (rewrite NX; apply freshn_nx_add).
  (* the meaning of every argument *)
  assert (DI : forall o ch, den E'' (init_cell kv rM o ch) = Mem.load ch m0 (e_blk E' rM) o).
  { intros o ch. rewrite (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E'' rM o ch EO'')).
    unfold addr. rewrite EB, EBs, HbM, Ptrofs.unsigned_zero. reflexivity. }
  assert (DIo : forall o ch, den E'' (init_cell kv rO o ch) = Mem.load ch m0 (e_blk E' rO) (addr E' rO o)).
  { intros o ch. rewrite (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E'' rO o ch EO'')).
    unfold addr. rewrite EB, EBs. reflexivity. }
  assert (DS : forall o ch sx, sload nbase R0 kv g' rM o ch = Some sx ->
            den E'' sx = Mem.load ch m' (e_blk E' rM) o /\ sok nbase n sx).
  { intros o ch sx Lx.
    destruct (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                E' m' g' rM o ch sx MM' Lx) as [Ld Sk].
    split; [| exact Sk].
    rewrite (den_Rx ge m0 E' E'' n sx RX (proj1 Sk)). rewrite <- Ld.
    unfold addr. rewrite HbM, Ptrofs.unsigned_zero. reflexivity. }
  assert (DF : forall r1 o ch k, In (r1, o, ch, Sfresh k) (fents (mkeys rM rO) n) ->
            den E'' (Sfresh k) = Mem.load ch m' (e_blk E' r1) (addr E' r1 o)).
  { intros r1 o ch k I. cbn [SymExec2.den]. exact (updk_den m' (mkeys rM rO) E' n r1 o ch k I). }
  assert (AM : forall o, addr E' rM o = o)
    by (intros o; unfold addr; rewrite HbM, Ptrofs.unsigned_zero; reflexivity).
  destruct (DS _ _ _ La) as [Da Sa]. destruct (DS _ _ _ Ls) as [Ds Ss]. destruct (DS _ _ _ Lt) as [Dt St].
  assert (F1 := DF rM oY Mfloat32 n ltac:(cbn; left; reflexivity)).
  assert (F2 := DF rM oV Mfloat32 (Pos.succ n) ltac:(cbn; right; left; reflexivity)).
  assert (F3 := DF rM oF Mfloat32 (Pos.succ (Pos.succ n)) ltac:(cbn; right; right; left; reflexivity)).
  assert (F4 := DF rO oG Mfloat32 (Pos.succ (Pos.succ (Pos.succ n)))
                  ltac:(cbn; right; right; right; left; reflexivity)).
  rewrite AM in F1, F2, F3.
  assert (Dr : den E'' r = Some v) by (rewrite (den_Rx ge m0 E' E'' n r RX (proj1 S)); exact D).
  exists E''.
  split; [ eapply Ext_trans; [exact X | apply Rx_Ext; exact RX | exact L] |].
  split.
  - apply MMg_add_fact; [exact M2 | |].
    + cbn [fact_nlt map pkeys mkeys app fents ic_of sv_of].
      assert (Hf : forall j, (j < 4)%nat -> nlt (g_nx g'') (Sfresh (Pos.of_nat (Pos.to_nat n + j)))).
      { intros j J. cbn [nlt]. rewrite NX4. unfold Plt. apply Pos2Nat.inj_lt.
        rewrite !Nat2Pos.id by lia. lia. }
      assert (Hi : forall r1 o ch, Plt r1 nbase -> nlt (g_nx g'') (init_cell kv r1 o ch)).
      { intros r1 o ch P. eapply sok_up; [exact (proj2 (init_cell_den ge nbase R0 gtab kv m0 gp E'' r1 o ch EO'') P) |].
        eapply Ple_trans; [exact NBl | exact NN]. }
      pose proof (Hf 0%nat ltac:(lia)) as H0. pose proof (Hf 1%nat ltac:(lia)) as H1.
      pose proof (Hf 2%nat ltac:(lia)) as H2. pose proof (Hf 3%nat ltac:(lia)) as H3.
      rewrite Nat.add_0_r, Pos2Nat.id in H0.
      replace (Pos.of_nat (Pos.to_nat n + 1)) with (Pos.succ n) in H1
        by (apply Pos2Nat.inj; rewrite Nat2Pos.id by lia; rewrite Pos2Nat.inj_succ; lia).
      replace (Pos.of_nat (Pos.to_nat n + 2)) with (Pos.succ (Pos.succ n)) in H2
        by (apply Pos2Nat.inj; rewrite Nat2Pos.id by lia; rewrite !Pos2Nat.inj_succ; lia).
      replace (Pos.of_nat (Pos.to_nat n + 3)) with (Pos.succ (Pos.succ (Pos.succ n))) in H3
        by (apply Pos2Nat.inj; rewrite Nat2Pos.id by lia; rewrite !Pos2Nat.inj_succ; lia).
      repeat constructor; try assumption; try (apply Hi; assumption);
        try (eapply sok_up; [eassumption | exact NN]).
    + cbn [fact_holds]. apply HUM. intros c Hent Hact Hb FRO.
      cbn [map pkeys mkeys app fents ic_of sv_of firstn skipn] in Hent.
      rewrite !DI, DIo in Hent. cbn [cvals map] in Hent.
      injection Hent as HA HS HT HY HV HF HG.
      destruct (step_cells ge nbase R0 gtab kv m0 uf gp gp_old E' m' g' rM rO kH MM' HUH HbM FD cl c CL
                  HA HS HT HY HV HF Hact Hb FRO) as (c1 & AC).
      exists cl, v, c1. split.
      * cbn [map pkeys mkeys app fents ic_of sv_of].
        rewrite F1, F2, F3, F4, Da, Ds, Dt, Dr, !DI, DIo, HA, HS, HT, HY, HV, HF, HG.
        destruct AC as (A1 & S1 & T1 & Y1 & V1 & Fl1 & G1).
        rewrite A1, S1, T1, Y1, V1, Fl1, G1. reflexivity.
      * exact (pmv_of ge nbase R0 gtab kv m0 uf gp gp_old E' m' g' rM rO kH MM' HUH HbM FD cl c c1 CL
                 HA HS HT HY HV HF AC Hact Hb FRO).
  - split; [exact Dr |].
    split; [cbn [add_fact g_nx]; split; [eapply nlt_up; [exact (proj1 S) | exact NN] | exact (proj2 S)] |].
    split; [cbn [add_fact g_nx]; eapply Ple_trans; [exact L | exact NN] |].
    cbn [add_fact g_loc]. rewrite LC. exact G.
Qed.
End ABSS.

(* ---------------------------------------------------------------------- *)
(* THE CONTRACT: run the callee, abstract every outcome, group            *)
(* ---------------------------------------------------------------------- *)

Section CPAS.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)).
Variables (xcI : ident -> option xcontract) (jkI : list (positive * Z * memory_chunk))
  (mergeI : ident -> bool) (fuel : nat) (fdP : fundef).
Variables (rM rO kH kM : positive).

Definition c_pas : xcontract := fun args g =>
  match sx_call ge nbase R0 gtab kv xcI jkI mergeI true fuel g fdP args with
  | Some cs =>
      match omap (absM nbase R0 kv rM rO kH kM) cs with
      | Some cs' => jgroup_c nbase R0 kv jkI cs'
      | None => None
      end
  | None => None
  end.

Variables (m0 : mem) (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis m0_closed : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.
(* the inner table is sound *)
Hypothesis XSI : forall id k args g cps fd E m vargs t m' vres,
  xcI id = Some k -> k args g = Some cps -> sfun_lookup ge id = Some fd ->
  MMg ge nbase R0 gtab kv m0 uf gp E m g ->
  Forall2 (fun a v => den ge m0 E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m fd vargs t m' vres ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Variable idM : ident.
Hypothesis Hgt : gfind gtab idM = Some rM.
Hypothesis HrO : Plt rO nbase.
Hypothesis HUH : forall vs, uf kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at ge m0) (ycast yv) h /\ Hit_at ge m0 h.
Hypothesis HUM : forall vs, MV vs -> uf kM vs.
Hypothesis FD : floor_data ge m0.

Theorem c_pas_sound : forall args g cps E m vargs t m' vres,
  c_pas args g = Some cps -> MMg ge nbase R0 gtab kv m0 uf gp E m g ->
  Forall2 (fun a v => den ge m0 E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m fdP vargs t m' vres ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres H MM HA EV. unfold c_pas in H.
  destruct (sx_call ge nbase R0 gtab kv xcI jkI mergeI true fuel g fdP args) as [cs|] eqn:RUN;
    [| discriminate H].
  destruct (omap (absM nbase R0 kv rM rO kH kM) cs) as [cs'|] eqn:AB; [| discriminate H].
  destruct (sx_call_sound ge nbase R0 gtab kv xcI jkI mergeI true m0 uf gp gp_old m0_closed XSI
              fuel g fdP args cs E m vargs t m' vres RUN MM HA EV) as (c & Ic & Cc).
  destruct (omap_in _ _ _ _ AB Ic) as (c1 & Ac & Ic1).
  pose proof (absM_sound ge nbase R0 gtab kv m0 uf gp gp_old rM rO kH kM idM Hgt HrO HUH HUM FD
                _ _ _ _ _ c c1 Ac Cc) as Cc1.
  exact (jgroup_c_cover ge nbase R0 gtab kv xcI jkI mergeI m0 uf gp gp_old m0_closed
           E (g_nx g) (g_loc g) m' vres cs' cps c1 H Ic1 Cc1).
Qed.
End CPAS.
