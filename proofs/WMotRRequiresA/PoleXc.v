(* ====================================================================== *)
(* PoleXc (GOAL 2): value contracts the pole walks need beyond AirXc's.   *)
(*                                                                        *)
(*   is_anim_at_end (mario.c): no locals, no stores, no calls, and it      *)
(*   returns a comparison, so a call leaves memory IDENTICAL and returns   *)
(*   an int (SymExec2.xc_fresh).  Proved from its generated body.          *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Cop Clight
  ClightBigstep.
From SM64.Generated Require mario surface_collision.
From SM64.Proofs Require Import Interp.SymExec2 WMotRRequiresA.FloorList WMotRRequiresA.TerrainSound
  WMotRRequiresA.FloorHeight WMotRRequiresA.FloorExec WMotRRequiresA.CeilExec.
Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* The two surface contracts, with the height facts the pole walks read.  *)
(*                                                                        *)
(* c_ff2: FloorExec.c_ff, whose NULL-floor outcome also records          *)
(*   Fuser kL [height; yPos]: the height is in FloorHeight.HPi (it is     *)
(*   -11000 there, but HPi is all a consumer needs).                      *)
(* c_fc2: CeilExec.c_fc, whose outcomes both record Fuser kC [height;     *)
(*   yPos]: find_ceil's height is 20000 (CELL_HEIGHT_LIMIT) or passed    *)
(*   find_ceil_from_list's test `y - (height - -78.0f) > 0` FALSE         *)
(*   (surface_collision.c), y the s16 cast of yPos.                       *)
(* ---------------------------------------------------------------------- *)

Definition c_ff2 (nbase : positive) (R0 : list (positive * Z)) (rFI rMS rCL kW kH kS kL : positive)
    (szS : Z) : xcontract := fun args g =>
  match args, c_ff nbase R0 rFI rMS rCL kW kH kS szS args g with
  | [_; ay; _; _], Some [(gN, r); c2] => Some [(add_fact gN (Fuser kL [r; ay]), r); c2]
  | _, _ => None
  end.

Definition c_fc2 (nbase : positive) (R0 : list (positive * Z)) (rCL kW kC : positive)
    (szS : Z) : xcontract := fun args g =>
  match args, c_fc nbase R0 rCL kW szS args g with
  | [_; ay; _; _], Some [(gN, r); (gS, r')] =>
      Some [(add_fact gN (Fuser kC [r; ay]), r); (add_fact gS (Fuser kC [r'; ay]), r')]
  | _, _ => None
  end.

(* find_ceil's height test, on the s16 y it computes from yPos *)
Definition c20000 : float32 := Float32.of_int (Int.repr 20000).
Definition ceil_ok (yv : val) (h : float32) : Prop :=
  h = c20000
  \/ exists yi, ycast yv = Vint yi
       /\ Float32.cmp Cgt (Float32.sub (Float32.of_int yi) (Float32.sub h (Float32.neg c78)))
            Float32.zero = false.

(* LABELED OPEN PREMISE (pole walks): the real find_ceil returns 20000 or a
   height that passed find_ceil_from_list's test.  A statement about the
   generated Clight of find_ceil / find_ceil_from_list (CeilList proves
   their memory effect; this is their returned value), to be discharged
   like FloorHeight.ff_height. *)
Definition find_ceil_height (ge : genv) : Prop :=
  forall m xv yv zv pc t m' vres,
    eval_funcall function_entry2 ge m (Internal surface_collision.f_find_ceil) [xv; yv; zv; pc] t m' vres ->
    exists h, vres = Vsingle h /\ ceil_ok yv h.

Lemma anim_end_nc : nc_chk (fn_body mario.f_is_anim_at_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* a comparison evaluates to an int *)
Lemma sem_cmp_int : forall c v1 t1 v2 t2 m v,
  sem_cmp c v1 t1 v2 t2 m = Some v -> exists i, v = Vint i.
Proof.
  intros c v1 t1 v2 t2 m v H.
  assert (OB : forall b, exists i, Val.of_bool b = Vint i)
    by (intros []; [exists Int.one | exists Int.zero]; reflexivity).
  unfold sem_cmp, cmp_ptr, sem_binarith, option_map in H.
  repeat match type of H with
         | context [match ?x with _ => _ end] => destruct x
         end;
    try discriminate H; injection H as <-; apply OB.
Qed.

(* THE VALUE CONTRACT of is_anim_at_end: memory unchanged, an int result *)
Theorem anim_end_value_contract : forall (ge : genv) m vargs t m' vres,
    eval_funcall function_entry2 ge m (Internal mario.f_is_anim_at_end) vargs t m' vres ->
    m' = m /\ exists i, vres = Vint i.
Proof.
  intros ge m vargs t m' vres Hevf. inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [mario.f_is_anim_at_end fn_vars] in Ha; inv Ha end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    pose proof (nc_walk _ _ _ _ _ _ _ _ _ Hx anim_end_nc) as -> end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
    rewrite (eq_refl : blocks_of_env ge empty_env = nil) in Hf;
    cbn [Mem.free_list] in Hf; injection Hf as <- end.
  split; [reflexivity |].
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [mario.f_is_anim_at_end fn_body] in Hx; rename Hx into Hb end.
  repeat (inv Hb; [| match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end; congruence];
          match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end;
          match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename H into Hb end).
  inv Hb.
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [fn_return mario.f_is_anim_at_end] in Ho; destruct Ho as (_ & Hc) end.
  match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    inv He; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end] end.
  match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
    cbn [sem_binary_operation] in Hs; destruct (sem_cmp_int _ _ _ _ _ _ _ Hs) as (i & ->) end.
  cbn in Hc. injection Hc as <-. cbn. eexists. reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* Adding a consumer fact about the returned value to a contract outcome  *)
(* ---------------------------------------------------------------------- *)
Lemma CM_add_user : forall ge nbase R0 gtab kv m0 uf gp E0 n0 gl m v g r k ay,
  CM ge nbase R0 gtab kv m0 uf gp E0 n0 gl m v (g, r) -> nlt n0 ay ->
  uf k [Some v; den ge m0 E0 ay] ->
  CM ge nbase R0 gtab kv m0 uf gp E0 n0 gl m v (add_fact g (Fuser k [r; ay]), r).
Proof.
  intros ge nbase R0 gtab kv m0 uf gp E0 n0 gl m v g r k ay (E & X & MMh & D & S & P & L) Na U.
  exists E. split; [exact X |]. split; [| split; [exact D | split; [exact S | split; [exact P | exact L]]]].
  apply MMg_add_fact; [exact MMh | |].
  - cbn [fact_nlt]. constructor; [eapply sok_nlt; exact S |]. constructor; [| constructor].
    exact (nlt_mono nbase (fun _ => None) (fun _ => false) uf _ _ _ Na P).
  - cbn [fact_holds map]. rewrite D.
    replace (den ge m0 E ay) with (den ge m0 E0 ay) by (symmetry; eapply den_ext; [exact Na | exact X]).
    exact U.
Qed.

(* ---------------------------------------------------------------------- *)
(* find_floor's height on BOTH outcomes (FloorExec.c_ff_sound proves it   *)
(* and records it on the surface outcome only): the setup of c_ff_sound,  *)
(* up to FloorHeight.ff_height                                             *)
(* ---------------------------------------------------------------------- *)
Section FF2.
Variable ge : genv.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables rFI rMS rCL kW kH kS kL kC : positive.
Variable szS : Z.

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).
Local Notation nb0 := (Mem.nextblock m0).
Local Notation den := (den ge m0).

Hypothesis HC : cenv_has ge.
Hypothesis Hpin : ffl_pinned ge.
Hypothesis Hcpin : CeilList.fcl_pinned ge.
Hypothesis HgFI : gfind gtab surface_collision._gFindFloorIncludeSurfaceIntangible = Some rFI.
Hypothesis HgMS : gfind gtab surface_collision._gNumFindFloorMisses = Some rMS.
Hypothesis HgCL : gfind gtab surface_collision._gNumCalls = Some rCL.
Hypothesis HU : forall vs, uf kW vs -> Wff ge m0 gp szS vs.
Hypothesis HUS : forall vs, surf_on m0 vs -> uf kS vs.
Hypothesis HUH : forall h yv, HPi (Hit_at ge m0) (ycast yv) h -> Hit_at ge m0 h ->
  uf kH [Some (Vsingle h); Some yv].
(* the two new consumer facts' meaning *)
Hypothesis HUL : forall h yv, HPi (Hit_at ge m0) (ycast yv) h -> uf kL [Some (Vsingle h); Some yv].
Hypothesis HUC : forall h yv, ceil_ok yv h -> uf kC [Some (Vsingle h); Some yv].

Local Notation statics_old := (FloorExec.statics_old ge m0 gp szS).
Local Notation wf_to_m := (FloorExec.wf_to_m ge nbase R0 gtab kv m0 uf gp).
Local Notation part_head_to_m0 := (FloorExec.part_head_to_m0 ge nbase R0 gtab kv m0 uf gp szS).
Local Notation on_list_to_m0 := (FloorExec.on_list_to_m0 ge nbase R0 gtab kv m0 uf gp).
Local Notation floor_head_to_m0 := (FloorExec.floor_head_to_m0 ge nbase R0 gtab kv m0 uf gp szS).
Local Notation ld_m0 := (FloorExec.ld_m0 ge nbase R0 gtab kv m0 uf gp).

Lemma c_ff_hpi : forall args g cps E m vargs t m' vres,
  c_ff nbase R0 rFI rMS rCL kW kH kS szS args g = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m (Internal surface_collision.f_find_floor) vargs t m' vres ->
  exists ay yv h, nth_error args 1 = Some ay /\ den E ay = Some yv /\ vres = Vsingle h
    /\ HPi (Hit_at ge m0) (ycast yv) h.
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
  destruct (PC _ IW) as (_ & HW). cbn [fact_holds] in HW. apply HU in HW.
  set (vs := map (den E) (wargs R0)) in *.
  pose proof HW as (WS & WP & WL & WSurf & WTy & WNS & Wsz).
  assert (Vm : forall b, Plt b nb0 -> Mem.valid_block m b)
    by (intros b Hb; eapply Plt_Ple_trans; [exact Hb | exact NX]).
  assert (HitM0 : forall h', Hit_at ge m h' -> Hit_at ge m0 h').
  { intros h' (hd & s & x & z & FH & OL & Ht).
    pose proof (floor_head_to_m0 E m g MMh hd HW FH) as FH0.
    pose proof (floor_head_part _ _ _ FH0) as PH0.
    pose proof (on_list_to_m0 E m g MMh hd s (WL hd PH0) OL) as OL0.
    destruct (WSurf hd s PH0 OL0) as (bs & os & -> & Ob & _ & NR & _).
    exists hd, (Vptr bs os), x, z. split; [exact FH0 | split; [exact OL0 |]].
    exact (hit16_transfer m m0 bs os x z h' (fun ch z' => ld_m0 E m g bs z' ch MMh Ob NR) Ht). }
  match goal with H : den E a2 = Some ?yv /\ _ |- _ => destruct H as (Dy & _); exists a2, yv end.
  destruct (ff_height ge HC Hpin m _ _ _ bpf op t m' vres Hvm
              ltac:(intros id b Hin Hs; apply Vm;
                    exact (statics_old _ _ HW (ex_intro _ id (conj Hin Hs))))
              ltac:(intros id bp Hin Hs; destruct (WP id bp Hin Hs) as (Old & _ & NS);
                    split; [exact (Vm _ Old) | split; [exact NS |]];
                    intros E'; apply Hnew; rewrite <- E'; exact Old)
              ltac:(intros hd PH; apply (wf_to_m E m g MMh bpf hd Hnew);
                    apply WL; exact (part_head_to_m0 E m g MMh hd HW PH))
              ltac:(intros hd s PH OL;
                    pose proof (part_head_to_m0 E m g MMh hd HW PH) as PH0;
                    pose proof (on_list_to_m0 E m g MMh hd s (WL hd PH0) OL) as OL0;
                    destruct (WSurf hd s PH0 OL0) as (bs & os & -> & Ob & _ & _ & _);
                    exists bs, os; split; [reflexivity | split; [exact (Vm _ Ob) |]];
                    split; [exact (WNS hd bs os PH0 OL0) | intros E'; apply Hnew; rewrite <- E'; exact Ob])
              ltac:(intros id b Hin Hs ->; exact (Hnew (statics_old _ _ HW (ex_intro _ id (conj Hin Hs)))))
              Hev)
    as (h & -> & HP & _).
  exists h. split; [reflexivity | split; [exact Dy | split; [reflexivity |]]].
  exact (HPi_mono _ _ _ _ HitM0 HP).
Qed.

(* THE SOUNDNESS of c_ff2 against the real find_floor *)
Theorem c_ff2_sound : forall args g cps E m vargs t m' vres,
  c_ff2 nbase R0 rFI rMS rCL kW kH kS kL szS args g = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m (Internal surface_collision.f_find_floor) vargs t m' vres ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres Hc MMh HF Hev.
  unfold c_ff2 in Hc.
  destruct args as [|a1 [|a2 [|a3 [|a4 [|a5 l]]]]]; try discriminate Hc.
  destruct (c_ff nbase R0 rFI rMS rCL kW kH kS szS [a1; a2; a3; a4] g) as [cps0|] eqn:C0;
    [| discriminate Hc].
  destruct cps0 as [|[gN r] [|c2 [|]]]; try discriminate Hc.
  injection Hc as <-.
  destruct (c_ff_sound ge nbase R0 gtab kv m0 uf gp gp_old rFI rMS rCL kW kH kS szS HC Hpin HgFI HgMS HgCL
              HU HUS HUH _ _ _ E m vargs t m' vres C0 MMh HF Hev) as (c & Hin & CMc).
  destruct (c_ff_hpi _ _ _ E m vargs t m' vres C0 MMh HF Hev) as (ay & yv & h & Nth & Dy & -> & HP).
  cbn in Nth. injection Nth as <-.
  assert (Na : nlt (g_nx g) a2).
  { inv HF. match goal with H : Forall2 _ _ _ |- _ => inv H end.
    match goal with H : den E a2 = Some _ /\ _ |- _ => destruct H as (_ & S) end.
    eapply sok_nlt; exact S. }
  destruct Hin as [<- | [<- | []]].
  - exists (add_fact gN (Fuser kL [r; a2]), r). split; [left; reflexivity |].
    apply CM_add_user; [exact CMc | exact Na |]. rewrite Dy. apply HUL. exact HP.
  - exists c2. split; [right; left; reflexivity | exact CMc].
Qed.

(* THE SOUNDNESS of c_fc2 against the real find_ceil, given its height
   (the labeled open premise find_ceil_height) *)
Theorem c_fc2_sound : find_ceil_height ge -> forall args g cps E m vargs t m' vres,
  c_fc2 nbase R0 rCL kW kC szS args g = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m (Internal surface_collision.f_find_ceil) vargs t m' vres ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros FCH args g cps E m vargs t m' vres Hc MMh HF Hev.
  unfold c_fc2 in Hc.
  destruct args as [|a1 [|a2 [|a3 [|a4 [|a5 l]]]]]; try discriminate Hc.
  destruct (c_fc nbase R0 rCL kW szS [a1; a2; a3; a4] g) as [cps0|] eqn:C0; [| discriminate Hc].
  destruct cps0 as [|[gN r] [|[gS r'] [|]]]; try discriminate Hc.
  injection Hc as <-.
  destruct (c_fc_sound ge nbase R0 gtab kv m0 uf gp gp_old rCL kW szS HC Hcpin HgCL HU
              _ _ _ E m vargs t m' vres C0 MMh HF Hev) as (c & Hin & CMc).
  inv HF. match goal with H : Forall2 _ _ _ |- _ => inv H end.
  match goal with H : Forall2 _ _ _ |- _ => inv H end.
  match goal with H : Forall2 _ _ _ |- _ => inv H end.
  match goal with H : Forall2 _ _ _ |- _ => inv H end.
  match goal with H : den E a2 = Some ?yv /\ _ |- _ => destruct H as (Dy & Sy) end.
  destruct (FCH _ _ _ _ _ _ _ _ Hev) as (h & -> & Hok).
  assert (Na : nlt (g_nx g) a2) by (eapply sok_nlt; exact Sy).
  destruct Hin as [<- | [<- | []]].
  - eexists. split; [left; reflexivity |].
    apply CM_add_user; [exact CMc | exact Na |]. rewrite Dy. apply HUC. exact Hok.
  - eexists. split; [right; left; reflexivity |].
    apply CM_add_user; [exact CMc | exact Na |]. rewrite Dy. apply HUC. exact Hok.
Qed.
End FF2.
