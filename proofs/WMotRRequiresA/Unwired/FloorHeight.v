(* ====================================================================== *)
(* FloorHeight (unwired, GOAL 2): the VALUE find_floor returns, proved from *)
(* its generated Clight body (surface_collision.c).                         *)
(*                                                                          *)
(* find_floor's result is read from its local `height`, which is only ever  *)
(* -11000 (the initial value), a height find_floor_from_list stored after   *)
(* its test  y - (h + -78.0f) < 0.0f  came out false (FloorList.hok, with   *)
(* y = the s16 cast of yPos), or the same for the SURFACE_INTANGIBLE        *)
(* re-search, whose y is (s32)(height - 200.0f).  Every stored height is   *)
(* also a HIT (FloorList.ffl_hit): the plane height of a surface on a      *)
(* partition list of the entry memory, at an (x, z) inside it.  [HPi Hit   *)
(* ys h] is exactly that set; [ff_height] proves every execution returns   *)
(* a member.                                                                *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs.WMotRRequiresA.Unwired Require Import FloorList.
Import ListNotations.

Definition c11000 : float32 := Float32.of_int (Int.neg (Int.repr 11000)).
Definition c200 : float32 := Float32.of_bits (Int.repr 1128792064).   (* 200.0f *)

(* the heights find_floor's `height` / `dynamicHeight` can hold, given the
   set Hit of heights find_floor_from_list can store *)
Inductive HPi (Hit : float32 -> Prop) (ys : val) : float32 -> Prop :=
  | hp_init : HPi Hit ys c11000
  | hp_ok : forall h, hok ys h -> Hit h -> HPi Hit ys h
  | hp_re : forall h0 y' h, HPi Hit ys h0 ->
      Float32.to_int (Float32.sub h0 c200) = Some y' -> hok (Vint y') h -> Hit h -> HPi Hit ys h.

Lemma HPi_mono : forall (H1 H2 : float32 -> Prop) ys h,
    (forall x, H1 x -> H2 x) -> HPi H1 ys h -> HPi H2 ys h.
Proof.
  intros H1 H2 ys h Hm H. induction H.
  - apply hp_init.
  - apply hp_ok; auto.
  - eapply hp_re; eauto.
Qed.

(* a height find_floor_from_list stored: a hit on a surface of a partition
   list of memory m *)
Definition Hit_at (ge : genv) (m : mem) (h : float32) : Prop :=
  exists hd s xv zv, part_head ge m hd /\ on_list m hd s /\ ffl_hit m s xv zv h.

(* the s16 cast of yPos, as the body computes it *)
Definition ycast (v : val) : val :=
  match v with
  | Vsingle f => match Float32.to_int f with
                 | Some i => Vint (Int.sign_ext 16 (Int.sign_ext 16 i))
                 | None => Vundef
                 end
  | _ => Vundef
  end.

(* ---- moving list / hit facts between memories that agree off W ---- *)

Lemma ol_transfer : forall mb (W : block -> Prop) hd, wf_list mb W hd ->
    forall M s, (forall b z, ~ W b -> Mem.load Mint32 M b z = Mem.load Mint32 mb b z) ->
    on_list M hd s -> on_list mb hd s.
Proof.
  intros mb W hd Hw. induction Hw as [| bn on nx Hv Hav Hld Hw IH]; intros M s F OL; inv OL.
  - apply ol_here. cbn [Mem.loadv] in *. rewrite <- (F _ _ Hav). assumption.
  - cbn [Mem.loadv] in *.
    match goal with Hn : Mem.load _ M _ _ = Some ?nx' |- _ =>
      rewrite (F _ _ Hav) in Hn; rewrite Hld in Hn; injection Hn as <- end.
    eapply ol_next; [exact Hld | eapply IH; eauto].
Qed.

Lemma wf_weaken : forall m (A A' : block -> Prop) hd, wf_list m A hd ->
    (forall b, Mem.valid_block m b -> ~ A b -> ~ A' b) -> wf_list m A' hd.
Proof.
  intros m A A' hd W Hw. induction W as [| bn on nx Hv Hav Hld W IH]; [constructor |].
  apply wf_cons with nx; auto.
Qed.

Lemma hit_transfer : forall M mb b o xv zv h,
    (forall ch z, Mem.load ch M b z = Mem.load ch mb b z) ->
    ffl_hit M (Vptr b o) xv zv h -> ffl_hit mb (Vptr b o) xv zv h.
Proof.
  intros M mb b o xv zv h F (bs & os & X & Z & x1 & z1 & x2 & z2 & x3 & z3 & nx & ny & nz & oo & Es & R).
  injection Es as <- <-. cbn [Mem.loadv] in R. rewrite !F in R.
  exists b, o, X, Z, x1, z1, x2, z2, x3, z3, nx, ny, nz, oo. split; [reflexivity |]. exact R.
Qed.

(* triples whose abrupt exits see the outcome (the returned value) *)
Section TRH.
Variable ge : genv.
Variable e : env.

Definition trh (P : temp_env -> mem -> Prop) (s : statement)
    (Q : temp_env -> mem -> Prop) (R : outcome -> Prop) : Prop :=
  forall le M t le' M' out, P le M ->
    exec_stmt function_entry2 ge e le M s t le' M' out ->
    (out = Out_normal /\ Q le' M') \/ (out <> Out_normal /\ R out).

Lemma trh_seq : forall P s1 Q s2 Q' R,
    trh P s1 Q R -> trh Q s2 Q' R -> trh P (Ssequence s1 s2) Q' R.
Proof.
  intros P s1 Q s2 Q' R T1 T2 le M t le' M' out HP H. inv H.
  - match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ Out_normal,
                    H2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
      destruct (T1 _ _ _ _ _ _ HP H1) as [(_ & HQ) | (Hn & _)];
        [exact (T2 _ _ _ _ _ _ HQ H2) | congruence] end.
  - match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ _, Hne : _ <> Out_normal |- _ =>
      destruct (T1 _ _ _ _ _ _ HP H1) as [(-> & _) | (_ & HR)];
        [congruence | right; split; assumption] end.
Qed.

Lemma trh_ite : forall P a s1 s2 Q R,
    trh P s1 Q R -> trh P s2 Q R -> trh P (Sifthenelse a s1 s2) Q R.
Proof.
  intros P a s1 s2 Q R T1 T2 le M t le' M' out HP H. inv H.
  match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
    destruct b; [exact (T1 _ _ _ _ _ _ HP Hx) | exact (T2 _ _ _ _ _ _ HP Hx)] end.
Qed.

Lemma trh_skip : forall P R, trh P Sskip P R.
Proof. intros P R le M t le' M' out HP H. inv H. left; auto. Qed.

Lemma trh_ret : forall (P : temp_env -> mem -> Prop) a Q (R : outcome -> Prop),
    (forall le M v, P le M -> eval_expr ge e le M a v -> R (Out_return (Some (v, typeof a)))) ->
    trh P (Sreturn (Some a)) Q R.
Proof.
  intros P a Q R PR le M t le' M' out HP H.
  inv H; right; split; try discriminate; eauto.
Qed.

Lemma trh_set : forall (P : temp_env -> mem -> Prop) x a R,
    (forall le M v, P le M -> eval_expr ge e le M a v -> P (PTree.set x v le) M) ->
    trh P (Sset x a) P R.
Proof. intros P x a R HS le M t le' M' out HP H. inv H. left; eauto. Qed.

Lemma trh_assign : forall (P : temp_env -> mem -> Prop) lhs rhs R,
    (forall le M b ofs bf v v' M', P le M ->
       eval_lvalue ge e le M lhs b ofs bf -> eval_expr ge e le M rhs v ->
       sem_cast v (typeof rhs) (typeof lhs) M = Some v' ->
       assign_loc ge (typeof lhs) M b ofs bf v' M' -> P le M') ->
    trh P (Sassign lhs rhs) P R.
Proof. intros P lhs rhs R HS le M t le' M' out HP H. inv H. left; eauto. Qed.
End TRH.

Lemma ycast_ok : forall yp v1 v M M',
    sem_cast yp tfloat tshort M = Some v1 -> sem_cast v1 tshort tshort M' = Some v -> v = ycast yp.
Proof.
  intros yp v1 v M M' H1 H2. unfold sem_cast in H1.
  destruct (intsize_eq I16 IBool) as [Hb|_]; [discriminate Hb |].
  destruct yp; cbn in H1; try discriminate H1.
  unfold ycast. unfold cast_single_int in H1.
  destruct (Float32.to_int f) as [i|]; [| discriminate H1].
  injection H1 as <-. unfold sem_cast in H2. cbn in H2. injection H2 as <-. reflexivity.
Qed.

Lemma sub_single : forall (ge : genv) hv c w m,
    sem_binary_operation ge Osub hv tfloat (Vsingle c) tfloat m = Some w ->
    exists h, hv = Vsingle h /\ w = Vsingle (Float32.sub h c).
Proof.
  intros ge hv c w m H. destruct hv; cbn in H; try discriminate H.
  all: try (injection H as <-; eauto).
  all: try (destruct Archi.ptr64; discriminate H).
Qed.

(* the temps that only ever hold copies of a height cell *)
Definition hts : list ident :=
  [surface_collision._t'7; surface_collision._t'9; surface_collision._t'10;
   surface_collision._t'11; surface_collision._t'14; surface_collision._t'16;
   surface_collision._t'17].

Section FH.
Variable ge : genv.
Variables bH bD bpf : block.
Variable opf : ptrofs.
Variable mb : mem.
Hypothesis HC : cenv_has ge.
Hypothesis Hpin : ffl_pinned ge.
Hypothesis HHD : bH <> bD.
Hypothesis HpH : bpf <> bH.
Hypothesis HpD : bpf <> bD.
Hypothesis Hgl : forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b -> b <> bH /\ b <> bD.
(* the blocks find_floor writes *)
Definition Wr (b : block) : Prop := b = bH \/ b = bD \/ b = bpf \/ is_static ge b.
Hypothesis Hpart : forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp -> ~ Wr bp.
Hypothesis Hwf : forall hd, part_head ge mb hd -> wf_list mb Wr hd.
Hypothesis Hsurf : forall hd s, part_head ge mb hd -> on_list mb hd s ->
  exists b o, s = Vptr b o /\ ~ Wr b.
Variable ys : val.
Local Notation e := (ffe bH bD).
Local Notation HP := (HPi (Hit_at ge mb) ys).

Definition HH (le : temp_env) (M : mem) : Prop :=
  (le ! surface_collision._y = Some ys \/ le ! surface_collision._y = Some Vundef)
  /\ (exists yp, le ! surface_collision._yPos = Some yp /\ ycast yp = ys)
  /\ (forall id h, In id hts -> le ! id = Some (Vsingle h) -> HP h)
  /\ (forall h, Mem.load Mfloat32 M bH 0 = Some (Vsingle h) -> HP h)
  /\ (forall h, Mem.load Mfloat32 M bD 0 = Some (Vsingle h) -> HP h)
  /\ le ! surface_collision._pfloor = Some (Vptr bpf opf)
  /\ (forall sl, le ! surface_collision._surfaceList = Some sl -> sl = Vundef \/ part_head ge mb sl)
  /\ (forall ch b z, ~ Wr b -> Mem.load ch M b z = Mem.load ch mb b z).

Definition RH (out : outcome) : Prop :=
  forall v ty, out = Out_return (Some (v, ty)) ->
    ty = tfloat /\ forall h, v = Vsingle h -> HP h.

Ltac idne := let HH := fresh in intro HH; cbv in HH; discriminate HH.
Ltac nin := let H := fresh in intro H; cbv in H;
  repeat (destruct H as [H|H]; [discriminate H |]); exact H.
Ltac inh := cbv; repeat (first [left; reflexivity | right]).

Lemma HH_set_other : forall le M x v, HH le M ->
    ~ In x hts -> x <> surface_collision._y -> x <> surface_collision._yPos ->
    x <> surface_collision._pfloor -> x <> surface_collision._surfaceList ->
    HH (PTree.set x v le) M.
Proof.
  intros le M x v (Y & YP & T & CH & CD & PF & SL & MF) Hx Hy Hyp Hpf Hsl.
  split; [rewrite PTree.gso by congruence; exact Y |].
  split; [rewrite PTree.gso by congruence; exact YP |].
  split; [intros id h Hin Hl; rewrite PTree.gso in Hl by (intros ->; contradiction); eauto |].
  split; [exact CH | split; [exact CD |]].
  split; [rewrite PTree.gso by congruence; exact PF |].
  split; [| exact MF].
  intros sl Hl. rewrite PTree.gso in Hl by congruence. eauto.
Qed.

(* a height variable's value *)
Lemma ev_cell : forall le M x v,
    (x = surface_collision._height \/ x = surface_collision._dynamicHeight) ->
    HH le M -> eval_expr ge e le M (Evar x tfloat) v ->
    v = Vundef \/ exists h, v = Vsingle h /\ HP h.
Proof.
  intros le M x v Hx (_ & _ & _ & CH & CD & _) H.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
  - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate.
    match goal with Ha : By_value _ = By_value _ |- _ => inv Ha end.
    match goal with Hl : Mem.load _ _ _ _ = Some _, He : e ! x = Some _ |- _ =>
      rewrite Ptrofs.unsigned_zero in Hl; rename Hl into HL; rename He into HE end.
    pose proof (Mem.load_type _ _ _ _ _ HL) as Ty.
    destruct v; cbn in Ty; try contradiction; [left; reflexivity | right; exists f; split; [reflexivity |]].
    destruct Hx as [-> | ->].
    + rewrite ffe_H in HE. inv HE. exact (CH _ HL).
    + rewrite ffe_D in HE. inv HE. exact (CD _ HL).
  - destruct Hx as [-> | ->]; [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate.
Qed.

Lemma HH_set_y : forall R,
  trh ge e HH (Sset surface_collision._y
                 (Ecast (Ecast (Etempvar surface_collision._yPos tfloat) tshort) tshort)) HH R.
Proof.
  intros R. apply trh_set. intros le M v (Y & (yp & Hyp & Hc) & T & CH & CD & PF & SL & MF) Hev.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : le ! surface_collision._yPos = Some _ |- _ => rewrite Hyp in Hx; inv Hx end.
  cbn [typeof] in *.
  match goal with H1 : sem_cast _ tfloat tshort _ = Some ?v1,
                  H2 : sem_cast ?v1 tshort tshort _ = Some _ |- _ =>
    pose proof (ycast_ok _ _ _ _ _ H1 H2) as Ev end.
  subst v. rewrite Hc.
  split; [left; apply PTree.gss |].
  split; [eexists; split; [rewrite PTree.gso by idne; exact Hyp | exact Hc] |].
  split; [intros id h Hin Hl; rewrite PTree.gso in Hl by (intros ->; revert Hin; nin); eauto |].
  split; [exact CH | split; [exact CD |]].
  split; [rewrite PTree.gso by idne; exact PF |].
  split; [| exact MF].
  intros sl Hl. rewrite PTree.gso in Hl by idne. eauto.
Qed.

Lemma HH_set_ht : forall tk x R, In tk hts ->
    (x = surface_collision._height \/ x = surface_collision._dynamicHeight) ->
    trh ge e HH (Sset tk (Evar x tfloat)) HH R.
Proof.
  intros tk x R Hk Hx. apply trh_set. intros le M v HI Hev.
  pose proof (ev_cell le M x v Hx HI Hev) as Hv.
  destruct HI as (Y & YP & T & CH & CD & PF & SL & MF).
  assert (Hy : tk <> surface_collision._y) by (intros ->; revert Hk; nin).
  assert (Hyp : tk <> surface_collision._yPos) by (intros ->; revert Hk; nin).
  assert (Hpf : tk <> surface_collision._pfloor) by (intros ->; revert Hk; nin).
  assert (Hsl : tk <> surface_collision._surfaceList) by (intros ->; revert Hk; nin).
  split; [rewrite PTree.gso by exact (not_eq_sym Hy); exact Y |].
  split; [destruct YP as (yp & ? & ?); exists yp; rewrite PTree.gso by exact (not_eq_sym Hyp); auto |].
  split; [| split; [exact CH | split; [exact CD |]]].
  - intros id h Hin Hl. destruct (peq id tk) as [-> | Hne].
    + rewrite PTree.gss in Hl. injection Hl as ->.
      destruct Hv as [Hd | (h' & Hh & Hp)]; [discriminate Hd | injection Hh as ->; exact Hp].
    + rewrite PTree.gso in Hl by exact Hne. eauto.
  - split; [rewrite PTree.gso by exact (not_eq_sym Hpf); exact PF |].
    split; [| exact MF].
    intros sl Hl. rewrite PTree.gso in Hl by exact (not_eq_sym Hsl). eauto.
Qed.

Ltac base_id A :=
  lazymatch A with
  | Evar ?x _ => x
  | Ebinop _ ?a1 _ _ => base_id a1
  | Ederef ?a1 _ => base_id a1
  end.

Lemma HH_set_sl : forall pid A R, In pid part_ids -> gaddr pid A = true ->
    trh ge e HH
      (Sset surface_collision._surfaceList
         (Efield (Ederef A (Tstruct surface_collision._SurfaceNode noattr))
            surface_collision._next (tptr (Tstruct surface_collision._SurfaceNode noattr)))) HH R.
Proof.
  intros pid A R Hin G. apply trh_set. intros le M v HI Hev.
  destruct HI as (Y & YP & T & CH & CD & PF & SL & MF).
  destruct (deref_field ge e le M A surface_collision._SurfaceNode surface_collision._next
              (tptr (Tstruct surface_collision._SurfaceNode noattr)) v SN_NEXT
              (fun co Hc => proj1 (sn_offsets_ge ge co HC Hc)) eq_refl Hev) as (l & ofs & HA & Hld).
  assert (Hne : e ! pid = None)
    by (apply ffe_other; destruct Hin as [<- | [<- | []]]; idne).
  destruct (gaddr_eval ge e _ _ pid Hne A _ G HA) as (bp & o & Hs & Eq). inv Eq.
  pose proof (Hpart pid bp Hin Hs) as Nw.
  split; [rewrite PTree.gso by idne; exact Y |].
  split; [destruct YP as (yp & ? & ?); exists yp; rewrite PTree.gso by idne; auto |].
  split; [intros id h Hi Hl; rewrite PTree.gso in Hl by (intros ->; revert Hi; nin); eauto |].
  split; [exact CH | split; [exact CD |]].
  split; [rewrite PTree.gso by idne; exact PF |].
  split; [| exact MF].
  intros sl Hl. rewrite PTree.gss in Hl. injection Hl as <-. right.
  exists pid, bp, (Ptrofs.add o (Ptrofs.repr SN_NEXT)). split; [exact Hin | split; [exact Hs |]].
  cbn [Mem.loadv] in *. rewrite <- (MF _ _ _ Nw). exact Hld.
Qed.

Lemma HH_assign_cell : forall x rhs R,
    (x = surface_collision._height \/ x = surface_collision._dynamicHeight) ->
    (forall le M v v' h, HH le M -> eval_expr ge e le M rhs v ->
       sem_cast v (typeof rhs) tfloat M = Some v' -> v' = Vsingle h -> HP h) ->
    trh ge e HH (Sassign (Evar x tfloat) rhs) HH R.
Proof.
  intros x rhs R Hx Hr. apply trh_assign.
  intros le M b ofs bf v v' M' HI Hl Hev Hc Ha.
  cbn [typeof] in Hc.
  pose proof (fun h => Hr _ _ _ _ h HI Hev Hc) as Hv.
  destruct HI as (Y & YP & T & CH & CD & PF & SL & MF).
  inv Hl; [| destruct Hx as [-> | ->]; [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate].
  inv Ha; cbn [access_mode] in *; try discriminate.
  try match goal with Hm : access_mode _ = By_value _ |- _ =>
    change (access_mode (typeof (Evar _ tfloat))) with (By_value Mfloat32) in Hm; inv Hm end.
  cbn [Mem.storev] in *. rewrite Ptrofs.unsigned_zero in *.
  match goal with Hs : Mem.store _ _ _ _ _ = Some _ |- _ => rename Hs into HS end.
  assert (Hcell : forall h, Mem.load Mfloat32 M' b 0 = Some (Vsingle h) -> HP h).
  { intros h Hld. rewrite (Mem.load_store_same _ _ _ _ _ _ HS) in Hld. injection Hld as Hld.
    destruct v'; cbn in Hld; try discriminate Hld. apply Hv. exact Hld. }
  assert (Hb : b = bH \/ b = bD)
    by (destruct Hx as [-> | ->];
        match goal with He : (ffe _ _) ! _ = Some _ |- _ =>
          first [rewrite ffe_H in He | rewrite ffe_D in He]; inv He end; auto).
  assert (MF' : forall ch b' z, ~ Wr b' -> Mem.load ch M' b' z = Mem.load ch mb b' z).
  { intros ch b' z Nw. rewrite <- (MF _ _ _ Nw). eapply Mem.load_store_other; [exact HS |].
    left. intros ->. apply Nw. destruct Hb as [-> | ->]; [left | right; left]; reflexivity. }
  split; [exact Y | split; [exact YP | split; [exact T |]]].
  destruct Hb as [-> | ->].
  - split; [exact Hcell | split; [| split; [exact PF | split; [exact SL | exact MF']]]].
    intros h Hld. apply CD. erewrite <- Mem.load_store_other; [exact Hld | exact HS |].
    left. exact (not_eq_sym HHD).
  - split; [| split; [exact Hcell | split; [exact PF | split; [exact SL | exact MF']]]].
    intros h Hld. apply CH. erewrite <- Mem.load_store_other; [exact Hld | exact HS |].
    left. exact HHD.
Qed.

Lemma HH_assign_other : forall lhs rhs R,
    (forall le M b ofs bf, HH le M -> eval_lvalue ge e le M lhs b ofs bf ->
       b = bpf \/ is_static ge b) ->
    trh ge e HH (Sassign lhs rhs) HH R.
Proof.
  intros lhs rhs R Hb. apply trh_assign.
  intros le M b ofs bf v v' M' HI Hl _ _ Ha.
  pose proof (Hb _ _ _ _ _ HI Hl) as Wb.
  assert (N1 : b <> bH) by (destruct Wb as [-> | (id & Hin & Hs)];
                             [exact HpH | exact (proj1 (Hgl id b Hin Hs))]).
  assert (N2 : b <> bD) by (destruct Wb as [-> | (id & Hin & Hs)];
                             [exact HpD | exact (proj2 (Hgl id b Hin Hs))]).
  destruct HI as (Y & YP & T & CH & CD & PF & SL & MF).
  assert (K : forall ch b' z, b' <> b -> Mem.load ch M' b' z = Mem.load ch M b' z).
  { intros ch b' z Hn. inv Ha.
    - cbn [Mem.storev] in *. eapply Mem.load_store_other; [eassumption | left; exact Hn].
    - eapply Mem.load_storebytes_other; [eassumption | left; exact Hn].
    - match goal with Hs : ?T |- _ => lazymatch T with context [store_bitfield] => inv Hs end end.
      eapply Mem.load_store_other; [eassumption | left; exact Hn]. }
  split; [exact Y | split; [exact YP | split; [exact T |]]].
  split; [intros h Hl'; apply CH; rewrite <- (K _ bH _ (not_eq_sym N1)); exact Hl' |].
  split; [intros h Hl'; apply CD; rewrite <- (K _ bD _ (not_eq_sym N2)); exact Hl' |].
  split; [exact PF | split; [exact SL |]].
  intros ch b' z Nw. rewrite <- (MF _ _ _ Nw). apply K.
  intros ->. apply Nw. right; right. exact Wb.
Qed.

Lemma lv_pf : forall ty ty' le M b ofs bf, HH le M ->
    eval_lvalue ge e le M (Ederef (Etempvar surface_collision._pfloor ty) ty') b ofs bf ->
    b = bpf \/ is_static ge b.
Proof.
  intros ty ty' le M b ofs bf (_ & _ & _ & _ & _ & Hp & _) H. inv H.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : le ! _ = Some (Vptr _ _) |- _ => rewrite Hp in Hx; inv Hx end.
  left. reflexivity.
Qed.

Lemma lv_st : forall x ty, In x ff_statics ->
    forall le M b ofs bf, HH le M -> eval_lvalue ge e le M (Evar x ty) b ofs bf ->
    b = bpf \/ is_static ge b.
Proof.
  intros x ty Hin le M b ofs bf _ Hl.
  destruct (lv_static ge bH bD x le M ty b ofs bf Hin Hl) as (Hs & _ & _).
  right. exists x. auto.
Qed.

Lemma lv_ncf : forall le M b ofs bf, HH le M ->
    eval_lvalue ge e le M
      (Efield (Evar surface_collision._gNumCalls (Tstruct surface_collision._NumTimesCalled noattr))
         surface_collision._floor tshort) b ofs bf ->
    b = bpf \/ is_static ge b.
Proof.
  intros le M b ofs bf _ Hl.
  destruct (lv_calls_floor ge bH bD HC le M b ofs bf Hl) as (Hs & _ & _).
  right. exists surface_collision._gNumCalls. split; [inh | exact Hs].
Qed.

Lemma c11000_ok : forall le M v v' h, HH le M ->
    eval_expr ge e le M (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint) v ->
    sem_cast v (typeof (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint)) tfloat M = Some v' ->
    v' = Vsingle h -> HP h.
Proof.
  intros le M v v' h _ Hev Hc ->.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Eunop _ _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hu : sem_unary_operation Oneg _ _ _ = Some _ |- _ =>
    unfold sem_unary_operation, sem_neg in Hu; cbn [typeof classify_neg] in Hu; injection Hu as <- end.
  unfold sem_cast in Hc. cbn [typeof classify_cast] in Hc. injection Hc as Hc.
  subst h. exact (hp_init _ ys).
Qed.

Lemma ht_rhs_ok : forall tk, In tk hts ->
    forall le M v v' h, HH le M -> eval_expr ge e le M (Etempvar tk tfloat) v ->
    sem_cast v (typeof (Etempvar tk tfloat)) tfloat M = Some v' -> v' = Vsingle h -> HP h.
Proof.
  intros tk Hk le M v v' h (_ & _ & T & _) Hev Hc ->.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  destruct v; cbn in Hc; try discriminate Hc. injection Hc as ->. eauto.
Qed.

Lemma ya_ok : forall le M v y h, HH le M ->
    eval_expr ge e le M (Etempvar surface_collision._y tshort) v ->
    sem_cast v (typeof (Etempvar surface_collision._y tshort)) tint M = Some y ->
    hok y h -> Hit_at ge mb h -> HP h.
Proof.
  intros le M v y h (Y & _) Hev Hc Hk Ht.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  assert (Ey : y = v)
    by (destruct v; cbn in Hc; try discriminate Hc; injection Hc as <-; reflexivity).
  subst y.
  destruct Y as [Y | Y]; rewrite Y in *;
    match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  - apply hp_ok; assumption.
  - destruct Hk as (yi & Hk & _). discriminate Hk.
Qed.

Lemma yre_ok : forall le M v y h, HH le M ->
    eval_expr ge e le M
      (Ecast (Ebinop Osub (Etempvar surface_collision._t'14 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat) tfloat) tint) v ->
    sem_cast v (typeof (Ecast (Ebinop Osub (Etempvar surface_collision._t'14 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat) tfloat) tint))
      tint M = Some y ->
    hok y h -> Hit_at ge mb h -> HP h.
Proof.
  intros le M v y h (_ & _ & T & _) Hev Hc Hk Ht.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ht : eval_expr _ _ _ _ (Econst_single _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_single _ _) _ _ _ |- _ => inv Hl end] end.
  cbn [typeof] in *.
  match goal with Hb : sem_binary_operation _ Osub _ tfloat (Vsingle _) tfloat _ = Some _ |- _ =>
    destruct (sub_single _ _ _ _ _ Hb) as (h0 & -> & ->) end.
  match goal with Hs : sem_cast (Vsingle _) tfloat tint _ = Some _ |- _ =>
    unfold sem_cast in Hs; cbn in Hs; try unfold cast_single_int in Hs;
    destruct (Float32.to_int (Float32.sub h0 (Float32.of_bits (Int.repr 1128792064)))) as [i|] eqn:Ti;
    [injection Hs as <- | discriminate Hs] end.
  unfold sem_cast in Hc. cbn in Hc. injection Hc as <-.
  eapply hp_re; [eapply T; [| eassumption]; inh | exact Ti | exact Hk | exact Ht].
Qed.

Lemma HH_call : forall tk tres cc loc bL a1 a2 a3 R,
    ((loc = surface_collision._height /\ bL = bH)
     \/ (loc = surface_collision._dynamicHeight /\ bL = bD)) ->
    ~ In tk hts -> tk <> surface_collision._y -> tk <> surface_collision._yPos ->
    tk <> surface_collision._pfloor -> tk <> surface_collision._surfaceList ->
    (forall le M v y h, HH le M -> eval_expr ge e le M a2 v ->
       sem_cast v (typeof a2) tint M = Some y -> hok y h -> Hit_at ge mb h -> HP h) ->
    trh ge e HH
      (Scall (Some tk)
         (Evar surface_collision._find_floor_from_list
            (Tfunction [tptr (Tstruct surface_collision._SurfaceNode noattr); tint; tint; tint;
                        tptr tfloat] tres cc))
         [Etempvar surface_collision._surfaceList
            (tptr (Tstruct surface_collision._SurfaceNode noattr));
          a1; a2; a3; Eaddrof (Evar loc tfloat) (tptr tfloat)])
      HH R.
Proof.
  intros tk tres cc loc bL a1 a2 a3 R Hloc Hn1 Hn2 Hn3 Hn4 Hn5 Ha2.
  intros le M t le' M' out HI H.
  assert (Hn : e ! surface_collision._find_floor_from_list = None) by (apply ffe_other; idne).
  destruct (ffl_call _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hpin Hn H)
    as (node & x & y & z & ph & fl0 & Hargs & -> & -> & Hres).
  left; split; [reflexivity |].
  pose proof (HH_set_other _ _ tk fl0 HI Hn1 Hn2 Hn3 Hn4 Hn5) as HI'.
  destruct Hres as [(-> & _) | (Hon & h & Hstv & Hk & Hhit)]; [exact HI' |].
  pose proof HI as (_ & _ & _ & _ & _ & _ & SL & MF).
  repeat match goal with Hl : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hl end.
  (* the list head: a partition head of mb *)
  match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._surfaceList _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hc : sem_cast _ (typeof (Etempvar surface_collision._surfaceList _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  match goal with Hx : le ! surface_collision._surfaceList = Some _ |- _ =>
    destruct (SL _ Hx) as [-> | PH] end.
  { inv Hon. }
  pose proof (ol_transfer _ _ _ (Hwf _ PH) M _ (fun b z Nw => MF Mint32 b z Nw) Hon) as OL.
  destruct (Hsurf _ _ PH OL) as (bs & os & -> & Nws).
  pose proof (hit_transfer M mb bs os _ _ _ (fun ch z => MF ch bs z Nws) Hhit) as Hhit'.
  assert (Ht : Hit_at ge mb h) by (do 4 eexists; split; [exact PH | split; [exact OL | exact Hhit']]).
  match goal with He : eval_expr _ _ _ _ a2 ?v, Hc : sem_cast ?v (typeof a2) tint _ = Some ?yy,
                  Hk : hok ?yy h |- _ => pose proof (Ha2 _ _ _ _ _ HI He Hc Hk Ht) as Hh end.
  match goal with Ha : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    [| destruct Hloc as [(-> & _) | (-> & _)];
       [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate].
  match goal with Hx : (ffe _ _) ! loc = Some (?bb, _) |- _ =>
    assert (Eb : bb = bL)
      by (destruct Hloc as [(-> & ->) | (-> & ->)];
          [rewrite ffe_H in Hx | rewrite ffe_D in Hx]; congruence);
    subst bb end.
  match goal with Hc : sem_cast _ (typeof (Eaddrof _ _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  cbn [Mem.storev] in Hstv. rewrite Ptrofs.unsigned_zero in Hstv.
  destruct HI' as (Y & YP & T & CH & CD & PF & SL' & MF').
  assert (MF'' : forall ch b' z, ~ Wr b' -> Mem.load ch M' b' z = Mem.load ch mb b' z).
  { intros ch b' zz Nw. rewrite <- (MF' _ _ _ Nw). eapply Mem.load_store_other; [exact Hstv |].
    left. intros ->. apply Nw.
    destruct Hloc as [(_ & ->) | (_ & ->)]; [left | right; left]; reflexivity. }
  split; [exact Y | split; [exact YP | split; [exact T |]]].
  destruct Hloc as [(-> & ->) | (-> & ->)].
  - split; [| split; [| split; [exact PF | split; [exact SL' | exact MF'']]]].
    + intros h' Hl. rewrite (Mem.load_store_same _ _ _ _ _ _ Hstv) in Hl.
      cbn in Hl. injection Hl as <-. exact Hh.
    + intros h' Hl. erewrite Mem.load_store_other in Hl;
        [exact (CD _ Hl) | exact Hstv | left; exact (not_eq_sym HHD)].
  - split; [| split; [| split; [exact PF | split; [exact SL' | exact MF'']]]].
    + intros h' Hl. erewrite Mem.load_store_other in Hl;
        [exact (CH _ Hl) | exact Hstv | left; exact HHD].
    + intros h' Hl. rewrite (Mem.load_store_same _ _ _ _ _ _ Hstv) in Hl.
      cbn in Hl. injection Hl as <-. exact Hh.
Qed.

Lemma HH_ret : forall tk, In tk hts ->
    trh ge e HH (Sreturn (Some (Etempvar tk tfloat))) HH RH.
Proof.
  intros tk Hk. apply trh_ret. intros le M v (_ & _ & T & _) Hev v' ty Ho.
  injection Ho as <- <-. split; [reflexivity |]. intros h ->.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  eauto.
Qed.

Ltac cellok := first [left; reflexivity | right; reflexivity].
Ltac locok := first [left; split; reflexivity | right; split; reflexivity].

Ltac solve_trh :=
  lazymatch goal with
  | |- trh _ _ _ (Ssequence _ _) _ _ => eapply (trh_seq _ _ _ _ HH); [solve_trh | solve_trh]
  | |- trh _ _ _ (Sifthenelse _ _ _) _ _ => eapply trh_ite; [solve_trh | solve_trh]
  | |- trh _ _ _ Sskip _ _ => apply trh_skip
  | |- trh _ _ _ (Sreturn _) _ _ => apply HH_ret; inh
  | |- trh _ _ _ (Scall _ _ _) _ _ =>
      eapply HH_call; [locok | nin | idne | idne | idne | idne | first [exact ya_ok | exact yre_ok]]
  | |- trh _ _ _ (Sset surface_collision._y _) _ _ => apply HH_set_y
  | |- trh _ _ _ (Sset surface_collision._surfaceList (Efield (Ederef ?A _) _ _)) _ _ =>
      let pid := base_id A in eapply (HH_set_sl pid); [inh | reflexivity]
  | |- trh _ _ _ (Sset _ _) _ _ =>
      first [ apply HH_set_ht; [inh | cellok]
            | apply trh_set; let HI := fresh in intros ? ? ? HI _;
              apply HH_set_other; [exact HI | nin | idne | idne | idne | idne] ]
  | |- trh _ _ _ (Sassign (Ederef (Etempvar surface_collision._pfloor _) _) _) _ _ =>
      apply HH_assign_other; apply lv_pf
  | |- trh _ _ _ (Sassign (Efield _ _ _) _) _ _ =>
      apply HH_assign_other; exact lv_ncf
  | |- trh _ _ _ (Sassign _ _) _ _ =>
      first [ apply HH_assign_cell; [cellok | first [exact c11000_ok | apply ht_rhs_ok; inh]]
            | apply HH_assign_other; apply lv_st; inh ]
  end.

Lemma ff_body_trh : trh ge e HH (fn_body surface_collision.f_find_floor) HH RH.
Proof. cbn [fn_body surface_collision.f_find_floor]. solve_trh. Qed.
End FH.

(* THE VALUE: whatever find_floor returns is in HPi for the s16 cast of its
   yPos argument, where every stored height is a hit on a surface of a
   partition list of the entry memory. *)
Theorem ff_height : forall (ge : genv), cenv_has ge -> ffl_pinned ge ->
    forall m xv yv zv bpf opf t m' vres,
      Mem.valid_block m bpf ->
      (forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b -> Mem.valid_block m b) ->
      (forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp ->
         Mem.valid_block m bp /\ ~ is_static ge bp /\ bp <> bpf) ->
      (forall hd, part_head ge m hd -> wf_list m (fun b => is_static ge b \/ b = bpf) hd) ->
      (forall hd s, part_head ge m hd -> on_list m hd s ->
         exists b o, s = Vptr b o /\ Mem.valid_block m b /\ ~ is_static ge b /\ b <> bpf) ->
      eval_funcall function_entry2 ge m (Internal surface_collision.f_find_floor)
        [xv; yv; zv; Vptr bpf opf] t m' vres ->
      exists h, vres = Vsingle h /\ HPi (Hit_at ge m) (ycast yv) h.
Proof.
  intros ge HC Hpin m xv yv zv bpf opf t m' vres Hpv Hsv Hpt Hwfm Hsm H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [surface_collision.f_find_floor fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
  match goal with
  | A1 : Mem.alloc m 0 _ = (?M1, ?b1), A2 : Mem.alloc ?M1 0 _ = (?M2, ?b2) |- _ =>
      rename b1 into bH, b2 into bD, A1 into HA1, A2 into HA2, M1 into mA, M2 into mB
  end.
  assert (HnvH : ~ Mem.valid_block m bH) by exact (Mem.fresh_block_alloc _ _ _ _ _ HA1).
  assert (HnvD : ~ Mem.valid_block m bD)
    by (intro HH; exact (Mem.fresh_block_alloc _ _ _ _ _ HA2 (Mem.valid_block_alloc _ _ _ _ _ HA1 _ HH))).
  assert (HHD : bH <> bD)
    by (intros E; subst; exact (Mem.fresh_block_alloc _ _ _ _ _ HA2 (Mem.valid_new_block _ _ _ _ _ HA1))).
  assert (Vne : forall b, Mem.valid_block m b -> b <> bH /\ b <> bD)
    by (intros b Hb; split; intros ->; contradiction).
  assert (Hgl : forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b -> b <> bH /\ b <> bD)
    by (intros id b Hin Hs; exact (Vne b (Hsv id b Hin Hs))).
  (* old blocks read the same in mB *)
  assert (LU : forall ch b z, Mem.valid_block m b -> Mem.load ch mB b z = Mem.load ch m b z).
  { intros ch b z Hb.
    rewrite (Mem.load_alloc_unchanged _ _ _ _ _ HA2 _ _ _ (Mem.valid_block_alloc _ _ _ _ _ HA1 _ Hb)).
    exact (Mem.load_alloc_unchanged _ _ _ _ _ HA1 _ _ _ Hb). }
  set (Wr0 := fun b => b = bH \/ b = bD \/ b = bpf \/ is_static ge b).
  assert (PH : forall hd, part_head ge mB hd <-> part_head ge m hd).
  { intros hd; split; intros (id & bp & o & Hin & Hs & Hl); exists id, bp, o;
      (split; [exact Hin | split; [exact Hs |]]); cbn [Mem.loadv] in *;
      destruct (Hpt id bp Hin Hs) as (Vb & _);
      [rewrite <- (LU _ _ _ Vb) | rewrite (LU _ _ _ Vb)]; exact Hl. }
  assert (WFm : forall hd, part_head ge m hd ->
                  wf_list m (fun b => is_static ge b \/ b = bpf \/ ~ Mem.valid_block m b) hd).
  { intros hd P. eapply wf_weaken; [exact (Hwfm hd P) |].
    intros b Vb Na [Hs | [Hb | Hn]]; [apply Na; left; exact Hs | apply Na; right; exact Hb | exact (Hn Vb)]. }
  assert (OLm : forall hd s, part_head ge m hd -> on_list mB hd s -> on_list m hd s).
  { intros hd s P OL. eapply ol_transfer; [exact (WFm hd P) | | exact OL].
    intros b z Nw. apply LU. destruct (Coqlib.plt b (Mem.nextblock m)) as [V | V]; [exact V |].
    exfalso. apply Nw. right; right. exact V. }
  assert (Hit_back : forall h, Hit_at ge mB h -> Hit_at ge m h).
  { intros h (hd & s & x & z & P & OL & Ht).
    apply PH in P. pose proof (OLm _ _ P OL) as OL'.
    destruct (Hsm _ _ P OL') as (b & o & -> & Vb & _ & _).
    exists hd, (Vptr b o), x, z. split; [exact P | split; [exact OL' |]].
    exact (hit_transfer mB m b o x z h (fun ch z' => LU ch b z' Vb) Ht). }
  (* the section's hypotheses, at mb := mB *)
  assert (Hpart : forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp -> ~ Wr0 bp).
  { intros id bp Hin Hs. destruct (Hpt id bp Hin Hs) as (Vb & Ns & Np).
    destruct (Vne _ Vb) as (N1 & N2).
    intros [E | [E | [E | E]]]; [exact (N1 E) | exact (N2 E) | exact (Np E) | exact (Ns E)]. }
  assert (Hwf : forall hd, part_head ge mB hd -> wf_list mB Wr0 hd).
  { intros hd P. apply PH in P. pose proof (Hwfm hd P) as W.
    clear P. induction W as [| bn on nx Hv Hav Hld W IH]; [constructor |].
    apply wf_cons with nx.
    - exact (Mem.valid_block_alloc _ _ _ _ _ HA2 _ (Mem.valid_block_alloc _ _ _ _ _ HA1 _ Hv)).
    - destruct (Vne _ Hv) as (N1 & N2).
      intros [E | [E | [E | E]]]; [exact (N1 E) | exact (N2 E) | apply Hav; right; exact E
                                    | apply Hav; left; exact E].
    - cbn [Mem.loadv] in *. rewrite (LU _ _ _ Hv). exact Hld.
    - exact IH. }
  assert (Hsurf : forall hd s, part_head ge mB hd -> on_list mB hd s ->
                    exists b o, s = Vptr b o /\ ~ Wr0 b).
  { intros hd s P OL. apply PH in P. pose proof (OLm _ _ P OL) as OL'.
    destruct (Hsm _ _ P OL') as (b & o & -> & Vb & Ns & Np).
    exists b, o. split; [reflexivity |]. destruct (Vne _ Vb) as (N1 & N2).
    intros [E | [E | [E | E]]]; [exact (N1 E) | exact (N2 E) | exact (Np E) | exact (Ns E)]. }
  destruct (Vne _ Hpv) as (HpH & HpD).
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ =>
    assert (HI : HH ge bH bD bpf opf mB (ycast yv) L mB);
    [cbn [bind_parameter_temps surface_collision.f_find_floor fn_params] in Hb; injection Hb as <- |]
  end.
  { split; [right; reflexivity |].
    split; [exists yv; split; reflexivity |].
    split.
    { intros id h Hin Hl. cbv in Hin.
      repeat (destruct Hin as [<- | Hin]; [cbv in Hl; discriminate Hl |]). contradiction. }
    split.
    { intros h Hl.
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ HA2 _ _ _ (Mem.valid_new_block _ _ _ _ _ HA1)) in Hl.
      apply (Mem.load_alloc_same _ _ _ _ _ HA1) in Hl. discriminate Hl. }
    split.
    { intros h Hl. apply (Mem.load_alloc_same _ _ _ _ _ HA2) in Hl. discriminate Hl. }
    split; [reflexivity |].
    split; [intros sl Hl; left; cbv in Hl; injection Hl as <-; reflexivity |].
    intros; reflexivity. }
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (ff_body_trh ge bH bD bpf opf mB HC Hpin HHD HpH HpD Hgl Hpart Hwf Hsurf (ycast yv)
                _ _ _ _ _ _ HI Hx)
      as [(-> & _) | (_ & HR)] end.
  { match goal with Ho : outcome_result_value _ _ _ _ |- _ => cbn in Ho; contradiction end. }
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [fn_return surface_collision.f_find_floor] in Ho; rename Ho into HO end.
  destruct out as [| | | [[v ty]|]]; cbn in HO; try contradiction.
  destruct HO as (_ & Hc).
  destruct (HR v ty eq_refl) as (-> & Hv).
  destruct v; cbn in Hc; try discriminate Hc. injection Hc as <-.
  exists f. split; [reflexivity |].
  exact (HPi_mono _ _ _ _ Hit_back (Hv f eq_refl)).
Qed.
