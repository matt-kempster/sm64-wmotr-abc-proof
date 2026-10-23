(* ====================================================================== *)
(* DmaContent (GOAL 2): what the REAL dma_read (memory.c) leaves in its   *)
(* destination when the source is Mario's animation data.                 *)
(*                                                                        *)
(* dma_read(dest, srcStart, srcEnd) rounds the size up to 16, invalidates *)
(* the destination's cache lines, and copies in chunks of at most 4096    *)
(* bytes: osPiStartDma(&gDmaIoMesg, 0, 0, (u32) srcStart, dest, copySize, *)
(* &gDmaMesgQueue); osRecvMesg(&gDmaMesgQueue, &gMainReceivedMesg, 1).    *)
(* dma_content, from the generated body (the loop by induction on its     *)
(* executions) and the floor (OsDmaFloor, TRUST 3.5, with the content     *)
(* clause pi_dma_anim_spec, TRUST 0.8(f)): for srcStart / srcEnd in        *)
(* gMarioAnims and a destination block apart from it and from the three   *)
(* DMA globals,                                                           *)
(*   - memory changes only in the n destination bytes and the three DMA   *)
(*     globals (n = the rounded size), with the same blocks and           *)
(*     permissions;                                                       *)
(*   - each of the n destination bytes whose source byte is readable      *)
(*     holds the source byte.                                             *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Memdata Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require memory game_init.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked CensusV2 OsDmaFloor LinkedTwelve LptBody.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

(* the rounded size dma_read copies, as its first statement computes it *)
Definition dma_n (s e : ptrofs) : int :=
  Int.and (Int.add (Ptrofs.to_int (Ptrofs.divs (Ptrofs.sub e s) (Ptrofs.repr 1))) (Int.repr 15))
          (Int.not (Int.repr 15)).

Definition dma_size_e : expr :=
  match fn_body memory.f_dma_read with Ssequence (Sset _ a) _ => a | _ => Etempvar xH tint end.
Definition dma_loop : statement :=
  match fn_body memory.f_dma_read with Ssequence _ (Ssequence _ l) => l | _ => Sskip end.
Definition dma_cond : expr :=
  match dma_loop with Sloop (Ssequence (Sifthenelse c _ _) _) _ => c | _ => Etempvar xH tint end.
Definition dma_body : statement :=
  match dma_loop with Sloop (Ssequence _ b) _ => b | _ => Sskip end.
Definition dma_inval : statement :=
  match fn_body memory.f_dma_read with Ssequence _ (Ssequence i _) => i | _ => Sskip end.

Lemma dma_shape : fn_body memory.f_dma_read
  = Ssequence (Sset memory._size dma_size_e) (Ssequence dma_inval dma_loop).
Proof. reflexivity. Qed.
Lemma dma_loop_shape : dma_loop = Sloop (Ssequence (Sifthenelse dma_cond Sskip Sbreak) dma_body) Sskip.
Proof. reflexivity. Qed.

Section DC.
Variable lp : Clight.program.
Hypothesis Hlink : linked12 lp.
Hypothesis Hfloor : os_dma_floor.
Hypothesis Hanim : pi_dma_anim_spec.
Variables bga biom bmq brm : block.
Hypothesis Hga : Genv.find_symbol (lp_ge lp) game_init._gMarioAnims = Some bga.
Hypothesis Hiom : Genv.find_symbol (lp_ge lp) memory._gDmaIoMesg = Some biom.
Hypothesis Hmq : Genv.find_symbol (lp_ge lp) memory._gDmaMesgQueue = Some bmq.
Hypothesis Hrm : Genv.find_symbol (lp_ge lp) memory._gMainReceivedMesg = Some brm.
Local Notation G := (lp_ge lp).

Lemma ga_iom : bga <> biom.
Proof. intros E. subst. exact (Genv.global_addresses_distinct G (id1 := game_init._gMarioAnims) (id2 := memory._gDmaIoMesg) ltac:(discriminate) Hga Hiom eq_refl). Qed.
Lemma ga_mq : bga <> bmq.
Proof. intros E. subst. exact (Genv.global_addresses_distinct G (id1 := game_init._gMarioAnims) (id2 := memory._gDmaMesgQueue) ltac:(discriminate) Hga Hmq eq_refl). Qed.
Lemma ga_rm : bga <> brm.
Proof. intros E. subst. exact (Genv.global_addresses_distinct G (id1 := game_init._gMarioAnims) (id2 := memory._gMainReceivedMesg) ltac:(discriminate) Hga Hrm eq_refl). Qed.

(* the footprint: the n bytes at the destination and the three globals *)
Definition dfoot (bd : block) (od : ptrofs) (n : Z) (b : block) (z : Z) : Prop :=
  outside bd od n b z /\ outside biom Ptrofs.zero SZ_IOMESG b z
  /\ outside bmq Ptrofs.zero SZ_MESGQ b z /\ outside brm Ptrofs.zero 4 b z.

Definition cont (m : mem) (b : block) (z : Z) : memval := ZMap.get z (Mem.mem_contents m) !! b.

(* a libultra call: its arguments as the callee's declared types cast them,
   and its external semantics *)
Lemma os_call2 : forall fid n le m fty al t le' m' out,
  mem_id fid os_ids = true -> ext_named ((prog_defmap memory.prog) ! fid) n = true ->
  exec_stmt function_entry2 G empty_env le m (Scall None (Evar fid fty) al) t le' m' out ->
  access_mode fty = By_reference ->
  exists sg tyargs tyres cc vargs vres, classify_fun fty = fun_case_f tyargs tyres cc
    /\ eval_exprlist G empty_env le m al tyargs vargs
    /\ external_functions_sem n sg G vargs m t vres m' /\ le' = le /\ out = Out_normal.
Proof.
  intros fid n le m fty al t le' m' out Hid Hn H Am.
  destruct (scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ H (PTree.gempty _ _) Am)
    as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hf & Hcl & Hel & Hev & -> & ->).
  destruct (os_resolve lp Hlink _ _ _ _ Hid Hn Hs Hf) as (sg & targs & tres & cc' & ->).
  inv Hev. exists sg, tyargs, tyres, cc, vargs, vres.
  split; [exact Hcl | split; [exact Hel | split; [| auto]]].
  match goal with Hx : external_call _ _ _ _ _ _ _ |- _ => exact Hx end.
Qed.

Ltac inv_ev :=
  repeat match goal with
  | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv H
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H
  | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv H
  | H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ => inv H
  | H : eval_expr _ _ _ _ (Eunop _ _ _) _ |- _ => inv H
  | H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H
  | H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H
  | H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H
  | H : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv H
  | H : eval_lvalue _ _ _ _ (Eunop _ _ _) _ _ _ |- _ => inv H
  end.

Lemma glob_addr : forall le m g ty ty' v bg,
  Genv.find_symbol G g = Some bg ->
  eval_expr G empty_env le m (Eaddrof (Evar g ty) ty') v -> v = Vptr bg Ptrofs.zero.
Proof.
  intros le m g ty ty' v bg Hs H.
  destruct (addrof_glob_val lp _ _ _ _ _ _ H) as (bg' & Hs' & ->). congruence.
Qed.

Lemma sz_rng : forall n k, 0 <= k <= n -> n <= Int.max_unsigned ->
  Int.unsigned (Int.repr (n - k)) = n - k.
Proof. intros n k H1 H2. apply Int.unsigned_repr. lia. Qed.


(* statements that always end normally *)
Fixpoint simple (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Scall None _ _ => true
  | Ssequence a b => simple a && simple b
  | Sifthenelse _ a b => simple a && simple b
  | _ => false
  end.

Lemma simple_normal : forall e s le m t le' m' o,
  simple s = true -> exec_stmt function_entry2 G e le m s t le' m' o -> o = Out_normal.
Proof.
  intros e s. induction s; intros le m t le' m' oo Hs H; cbn in Hs; try discriminate Hs.
  - inv H; reflexivity.
  - inv H; reflexivity.
  - inv H; reflexivity.
  - apply andb_prop in Hs as [H1 H2]. inv H; [ eapply IHs2; eassumption | ].
    match goal with Hx : exec_stmt _ _ _ _ _ s1 _ _ _ ?o', Hn : ?o' <> Out_normal |- _ =>
      exfalso; exact (Hn (IHs1 _ _ _ _ _ _ H1 Hx)) end.
  - apply andb_prop in Hs as [H1 H2]. inv H.
    match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
      destruct b; [ eapply IHs1 | eapply IHs2 ]; eassumption end.
Qed.

Lemma seq_inv : forall e le m s1 s2 t le' m' out,
  simple s1 = true ->
  exec_stmt function_entry2 G e le m (Ssequence s1 s2) t le' m' out ->
  exists t1 le1 m1 t2, exec_stmt function_entry2 G e le m s1 t1 le1 m1 Out_normal
    /\ exec_stmt function_entry2 G e le1 m1 s2 t2 le' m' out.
Proof.
  intros e le m s1 s2 t le' m' out Hs H. inv H.
  - do 4 eexists. split; eassumption.
  - match goal with Hx : exec_stmt _ _ _ _ _ s1 _ _ _ ?o, Hn : ?o <> Out_normal |- _ =>
      exfalso; exact (Hn (simple_normal _ _ _ _ _ _ _ _ Hs Hx)) end.
Qed.

Lemma bool_of_bool : forall x m, bool_val (Val.of_bool x) tint m = Some x.
Proof. intros [|] m; reflexivity. Qed.

Lemma cmp_ge : forall sz m, 0 <= sz <= Int.max_unsigned ->
  sem_binary_operation (genv_cenv G) Oge (Vint (Int.repr sz)) tuint (Vint (Int.repr 4096)) tint m
  = Some (Val.of_bool (negb (sz <? 4096))).
Proof.
  intros sz m R. cbn. unfold sem_binarith, sem_cast, Archi.ptr64. cbn. unfold Int.ltu. rewrite (Int.unsigned_repr sz) by exact R. rewrite (Int.unsigned_repr 4096) by (cbn; lia).
  destruct (zlt sz 4096) as [L | L]; destruct (Z.ltb_spec sz 4096); try lia; reflexivity.
Qed.

Lemma cmp_ne : forall sz m, 0 <= sz <= Int.max_unsigned ->
  sem_binary_operation (genv_cenv G) One (Vint (Int.repr sz)) tuint (Vint (Int.repr 0)) tint m
  = Some (Val.of_bool (negb (sz =? 0))).
Proof.
  intros sz m R. cbn. unfold sem_binarith, sem_cast, Archi.ptr64. cbn. unfold Int.eq. rewrite (Int.unsigned_repr sz) by exact R. try rewrite (Int.unsigned_repr 0) by (cbn; lia).
  destruct (zeq sz 0) as [L | L]; destruct (Z.eqb_spec sz 0); try lia; reflexivity.
Qed.

Lemma sub_u : forall a b m, 0 <= b <= a -> a <= Int.max_unsigned ->
  sem_binary_operation (genv_cenv G) Osub (Vint (Int.repr a)) tuint (Vint (Int.repr b)) tuint m
  = Some (Vint (Int.repr (a - b))).
Proof.
  intros a b m R1 R2. cbn. unfold sem_binarith, sem_cast, Archi.ptr64. cbn. unfold Int.sub. rewrite (Int.unsigned_repr a), (Int.unsigned_repr b) by lia. reflexivity.
Qed.

Lemma add_pu : forall bb (o : ptrofs) c m,
  sem_binary_operation (genv_cenv G) Oadd (Vptr bb o) (tptr tuchar) (Vint c) tuint m
  = Some (Vptr bb (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr (sizeof (genv_cenv G) tuchar))
                                   (ptrofs_of_int Unsigned c)))).
Proof. intros. reflexivity. Qed.

Lemma ptr_add_u : forall (o : ptrofs) (c : int),
  Ptrofs.unsigned o + Int.unsigned c < Ptrofs.modulus ->
  Ptrofs.unsigned (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr (sizeof (genv_cenv G) tuchar))
                                   (ptrofs_of_int Unsigned c)))
  = Ptrofs.unsigned o + Int.unsigned c.
Proof.
  intros o c H. cbn [sizeof]. rewrite Ptrofs.mul_commut, Ptrofs.mul_one.
  unfold ptrofs_of_int, Ptrofs.of_intu, Ptrofs.of_int.
  unfold Ptrofs.add. rewrite (Ptrofs.unsigned_repr (Int.unsigned c)).
  - apply Ptrofs.unsigned_repr. pose proof (Ptrofs.unsigned_range o). pose proof (Int.unsigned_range c).
    unfold Ptrofs.max_unsigned. lia.
  - pose proof (Int.unsigned_range c). assert (Int.modulus = Ptrofs.modulus) by reflexivity.
    unfold Ptrofs.max_unsigned. lia.
Qed.

Ltac tgetH H := repeat (rewrite PTree.gss in H || (rewrite PTree.gso in H by (cbv; congruence))).
Ltac tget := repeat (rewrite PTree.gss || (rewrite PTree.gso by (cbv; congruence))).

(* resolve a temp read against a known value *)
Ltac rtemp :=
  repeat match goal with
  | H : ?l ! ?x = Some ?v, E : ?l ! ?x = Some ?w |- _ =>
      rewrite E in H; injection H as H; subst v
  end.

(* ---------------------------------------------------------------------- *)
(* The loop                                                                *)
(* ---------------------------------------------------------------------- *)
Section LOOP.
Variables (m : mem) (bd : block) (od s : ptrofs) (N : Z).
Hypothesis Hbd_ga : bd <> bga.
Hypothesis Hbd_iom : bd <> biom.
Hypothesis Hbd_mq : bd <> bmq.
Hypothesis Hbd_rm : bd <> brm.
Hypothesis HN : 0 <= N <= Int.max_unsigned.
Hypothesis Hod : Ptrofs.unsigned od + N < Ptrofs.modulus.
Hypothesis Hs : Ptrofs.unsigned s + N < Ptrofs.modulus.
Hypothesis Hperm : Mem.range_perm m bd (Ptrofs.unsigned od) (Ptrofs.unsigned od + N) Cur Readable.

Definition INV (k : Z) (le : temp_env) (mk : mem) : Prop :=
  0 <= k <= N
  /\ le ! memory._size = Some (Vint (Int.repr (N - k)))
  /\ (exists dk, le ! memory._dest = Some (Vptr bd dk) /\ Ptrofs.unsigned dk = Ptrofs.unsigned od + k)
  /\ (exists sk, le ! memory._srcStart = Some (Vptr bga sk) /\ Ptrofs.unsigned sk = Ptrofs.unsigned s + k)
  /\ Mem.unchanged_on (dfoot bd od N) m mk /\ same_perms m mk
  /\ (forall i, 0 <= i < k -> Mem.perm m bga (Ptrofs.unsigned s + i) Cur Readable ->
        cont mk bd (Ptrofs.unsigned od + i) = cont m bga (Ptrofs.unsigned s + i)).

Lemma ga_out : forall z, dfoot bd od N bga z.
Proof.
  intros z. split; [left; congruence |].
  split; [left; exact ga_iom |]. split; [left; exact ga_mq | left; exact ga_rm].
Qed.

(* one iteration *)
Lemma body_step : forall k le mk t le' m' out,
  INV k le mk -> k < N ->
  exec_stmt function_entry2 G empty_env le mk dma_body t le' m' out ->
  out = Out_normal /\ exists k', k < k' /\ INV k' le' m'.
Proof.
  intros k le mk t le' m' out I Hk H.
  destruct I as (Hk0 & Hsz & (dk & Hdk & Edk) & (sk & Hsk & Esk) & UO & SP & CT).
  unfold dma_body, dma_loop in H. cbn [memory.f_dma_read fn_body] in H.
  apply seq_inv in H as (t1 & le1 & m1 & t2 & H1 & H); [ | reflexivity ].
  apply seq_inv in H1 as (t3 & le3 & m3 & t4 & Hif & Hcp); [ | reflexivity ].
  set (c := Z.min (N - k) 4096).
  assert (Hc : 0 < c <= N - k /\ c <= 4096) by (unfold c; lia).
  (* the size test and the chunk *)
  assert (E3 : le3 = PTree.set memory._t'1 (Vint (Int.repr c)) le /\ m3 = mk).
  { inv Hif. inv_ev. rtemp.
    match goal with Hb : sem_binary_operation _ Oge _ _ _ _ _ = Some _ |- _ =>
      rewrite cmp_ge in Hb by lia; injection Hb as <- end.
    match goal with Hb : bool_val _ _ _ = Some _ |- _ => rewrite bool_of_bool in Hb; injection Hb as <- end.
    destruct (Z.ltb_spec (N - k) 4096) as [L | L]; cbn [negb] in *;
      match goal with Hx : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hx end;
      inv_ev; rtemp;
      match goal with Hcs : sem_cast _ _ _ _ = Some _ |- _ => unfold sem_cast, Archi.ptr64 in Hcs; cbn in Hcs; injection Hcs as <- end;
      (split; [ | reflexivity ]); unfold c;
      [ rewrite Z.min_l by lia | rewrite Z.min_r by lia ]; reflexivity. }
  destruct E3 as [-> ->].
  assert (E1 : le1 = PTree.set memory._copySize (Vint (Int.repr c))
                       (PTree.set memory._t'1 (Vint (Int.repr c)) le) /\ m1 = mk).
  { inv Hcp. inv_ev. rewrite PTree.gss in *.
    match goal with H : Some _ = Some _ |- _ => injection H as <- end. auto. }
  destruct E1 as [-> ->].
  apply seq_inv in H as (t5 & le5 & m5 & t6 & Hpi & H); [ | reflexivity ].
  apply seq_inv in H as (t7 & le7 & m7 & t8 & Hrv & H); [ | reflexivity ].
  apply seq_inv in H as (t9 & le9 & m9 & t10 & Hd & H); [ | reflexivity ].
  apply seq_inv in H as (t11 & le11 & m11 & t12 & Hsr & Hz); [ | reflexivity ].
  set (le1 := PTree.set memory._copySize (Vint (Int.repr c))
                (PTree.set memory._t'1 (Vint (Int.repr c)) le)) in *.
  assert (Ld : le1 ! memory._dest = Some (Vptr bd dk)) by (unfold le1; tget; exact Hdk).
  assert (Ls : le1 ! memory._srcStart = Some (Vptr bga sk)) by (unfold le1; tget; exact Hsk).
  assert (Lz : le1 ! memory._size = Some (Vint (Int.repr (N - k)))) by (unfold le1; tget; exact Hsz).
  assert (Lc : le1 ! memory._copySize = Some (Vint (Int.repr c))) by (unfold le1; tget; reflexivity).
  clearbody le1.
  assert (Uc : Int.unsigned (Int.repr c) = c) by (apply Int.unsigned_repr; lia).
  (* osPiStartDma *)
  destruct (os_call2 memory._osPiStartDma "osPiStartDma"%string _ _ _ _ _ _ _ _ eq_refl os_pidma_named Hpi eq_refl)
    as (sg & tyargs & tyres & cc & vargs & vres & Hcl & Hel & Hx & -> & _).
  cbn in Hcl. injection Hcl as <- <- <-.
  repeat match goal with H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end.
  repeat match goal with H : eval_expr _ _ _ _ (Eaddrof (Evar ?g _) _) _ |- _ =>
    first [ apply (glob_addr _ _ _ _ _ _ _ Hiom) in H | apply (glob_addr _ _ _ _ _ _ _ Hmq) in H ]; subst end.
  inv_ev. rtemp.
  repeat match goal with Hcs : sem_cast _ _ _ _ = Some _ |- _ => unfold sem_cast, Archi.ptr64 in Hcs; cbn in Hcs; injection Hcs as <- end.
  destruct Hfloor as (_ & Hpis & Hrvs & _).
  pose proof (Hanim _ _ _ _ _ _ _ _ Hx Hga _ _ _ _ _ _ _ _ eq_refl) as CP.
  destruct (Hpis _ _ _ _ _ _ _ Hx)
    as (bmb & omb & pri & dir & dev & bd' & od' & n & bq & oq & Ev & UO1 & SP1 & _ & _).
  injection Ev as <- <- <- <- <- <- <- <- <- <-.
  rewrite Uc in CP.
  (* osRecvMesg *)
  destruct (os_call2 memory._osRecvMesg "osRecvMesg"%string _ _ _ _ _ _ _ _ eq_refl os_recv_named Hrv eq_refl)
    as (sg2 & tyargs2 & tyres2 & cc2 & vargs2 & vres2 & Hcl2 & Hel2 & Hx2 & -> & _).
  cbn in Hcl2. injection Hcl2 as <- <- <-.
  repeat match goal with H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end.
  repeat match goal with H : eval_expr _ _ _ _ (Eaddrof (Evar ?g _) _) _ |- _ =>
    first [ apply (glob_addr _ _ _ _ _ _ _ Hmq) in H | apply (glob_addr _ _ _ _ _ _ _ Hrm) in H ]; subst end.
  inv_ev.
  repeat match goal with Hcs : sem_cast _ _ _ _ = Some _ |- _ => unfold sem_cast, Archi.ptr64 in Hcs; cbn in Hcs; injection Hcs as <- end.
  destruct (Hrvs _ _ _ _ _ _ _ Hx2) as (bq2 & oq2 & cell & fl & Ev2 & _ & SP2 & UQ).
  injection Ev2 as <- <- <- <-.
  pose proof (UQ memory._gDmaMesgQueue [] eq_refl Hmq) as UO2. clear UQ.
  (* the three pointer / size updates *)
  inv Hd. inv_ev. rtemp.
  match goal with Hb : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
    rewrite add_pu in Hb; injection Hb as <- end.
  inv Hsr. inv_ev. rewrite PTree.gso in * by (cbv; congruence). rtemp.
  match goal with Hb : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
    rewrite add_pu in Hb; injection Hb as <- end.
  inv Hz. inv_ev. rewrite !PTree.gso in * by (cbv; congruence). rtemp.
  match goal with Hb : sem_binary_operation _ Osub _ _ _ _ _ = Some _ |- _ =>
    rewrite sub_u in Hb by lia; injection Hb as <- end.
  split; [ reflexivity | ].
  exists (k + c). split; [ lia | ].
  assert (Dc : Ptrofs.unsigned dk + Int.unsigned (Int.repr c) < Ptrofs.modulus) by (rewrite Uc; lia).
  assert (Sc : Ptrofs.unsigned sk + Int.unsigned (Int.repr c) < Ptrofs.modulus) by (rewrite Uc; lia).
  split; [ lia | ].
  split; [ rewrite PTree.gss; do 2 f_equal; f_equal; lia | ].
  split.
  { eexists. rewrite PTree.gso by (cbv; congruence). rewrite PTree.gso by (cbv; congruence).
    rewrite PTree.gss. split; [ reflexivity | ]. rewrite ptr_add_u by exact Dc. lia. }
  split.
  { eexists. rewrite PTree.gso by (cbv; congruence). rewrite PTree.gss.
    split; [ reflexivity | ]. rewrite ptr_add_u by exact Sc. lia. }
  assert (UO12 : Mem.unchanged_on (dfoot bd od N) mk m').
  { eapply Mem.unchanged_on_trans.
    - eapply Mem.unchanged_on_implies; [ exact UO1 | ].
      intros b z (D1 & D2 & D3 & D4) _. rewrite Uc.
      split; [ | split; [ exact D2 | exact D3 ] ].
      destruct D1 as [D1 | [D1 | D1]]; [ left; exact D1 | right; left; lia | right; right; lia ].
    - eapply Mem.unchanged_on_implies; [ exact UO2 | ].
      intros b z (D1 & D2 & D3 & D4) _. split; [ exact D3 | split; [ exact D4 | intros ? [] ] ]. }
  split; [ eapply Mem.unchanged_on_trans; [ exact UO | exact UO12 ] | ].
  split.
  { destruct SP as (SPn & SPp). destruct SP1 as (SPn1 & SPp1). destruct SP2 as (SPn2 & SPp2).
    split; [ congruence | ]. intros b z kk p. rewrite SPp2, SPp1, SPp. tauto. }
  (* content *)
  assert (Pd : forall i, 0 <= i < N -> Mem.perm mk bd (Ptrofs.unsigned od + i) Cur Readable).
  { intros i Ri. destruct SP as (_ & SPp). apply SPp. apply Hperm. lia. }
  (* the recv leaves the destination bytes *)
  assert (R2 : forall i, 0 <= i < N -> cont m' bd (Ptrofs.unsigned od + i) = cont m5 bd (Ptrofs.unsigned od + i)).
  { intros i Ri. unfold cont. eapply Mem.unchanged_on_contents; [ exact UO2 | | ].
    - split; [ left; exact Hbd_mq | split; [ left; exact Hbd_rm | intros ? [] ] ].
    - destruct SP1 as (_ & SPp1). apply SPp1. exact (Pd i Ri). }
  intros i Ri Pg.
  rewrite R2 by lia.
  destruct (Z_lt_le_dec i k) as [Lk | Lk].
  - (* an earlier byte: the DMA leaves it *)
    unfold cont. erewrite Mem.unchanged_on_contents; [ | exact UO1 | | exact (Pd i ltac:(lia)) ].
    + exact (CT i (conj (proj1 Ri) Lk) Pg).
    + rewrite Uc. split; [ right; left; lia | split; [ left; exact Hbd_iom | left; exact Hbd_mq ] ].
  - (* a byte of this chunk: the DMA's content clause *)
    assert (Ei : Ptrofs.unsigned od + i = Ptrofs.unsigned dk + (i - k)) by lia.
    assert (Es : Ptrofs.unsigned s + i = Ptrofs.unsigned sk + (i - k)) by lia.
    rewrite Ei. unfold cont. rewrite (CP (i - k)); [ | lia | ].
    + rewrite <- Es. eapply Mem.unchanged_on_contents; [ exact UO | exact (ga_out _) | exact Pg ].
    + rewrite <- Es. destruct SP as (_ & SPp). apply SPp. exact Pg.
Qed.

Lemma cond_val : forall k le mk v b, INV k le mk ->
  eval_expr G empty_env le mk dma_cond v -> bool_val v (typeof dma_cond) mk = Some b ->
  b = negb (N - k =? 0).
Proof.
  intros k le mk v b I Hv Hb. destruct I as (R & Hsz & _).
  unfold dma_cond, dma_loop in *. cbn [memory.f_dma_read fn_body typeof Swhile] in *.
  inv_ev. rtemp.
  match goal with Hc : sem_binary_operation _ One _ _ _ _ _ = Some _ |- _ =>
    rewrite cmp_ne in Hc by lia; injection Hc as <- end.
  rewrite bool_of_bool in Hb. injection Hb as <-. reflexivity.
Qed.

Lemma s1_cases : forall k le mk t le1 m1 out1,
  INV k le mk ->
  exec_stmt function_entry2 G empty_env le mk
    (Ssequence (Sifthenelse dma_cond Sskip Sbreak) dma_body) t le1 m1 out1 ->
  (k = N /\ out1 = Out_break /\ le1 = le /\ m1 = mk)
  \/ (out1 = Out_normal /\ exists k', k < k' /\ INV k' le1 m1).
Proof.
  intros k le mk t le1 m1 out1 I H.
  assert (R : 0 <= k <= N) by (destruct I; lia).
  inv H.
  - match goal with Hx : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv Hx end.
    match goal with Hv : eval_expr _ _ _ _ dma_cond _, Hb : bool_val _ _ _ = Some ?b |- _ =>
      pose proof (cond_val _ _ _ _ _ I Hv Hb) as Eb end.
    match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then Sskip else Sbreak) _ _ _ _ |- _ =>
      destruct b; inv Hx end.
    right. destruct (Z.eqb_spec (N - k) 0); cbn in Eb; try discriminate Eb.
    eapply body_step; [ exact I | lia | eassumption ].
  - match goal with Hx : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv Hx end.
    match goal with Hv : eval_expr _ _ _ _ dma_cond _, Hb : bool_val _ _ _ = Some ?b |- _ =>
      pose proof (cond_val _ _ _ _ _ I Hv Hb) as Eb end.
    match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then Sskip else Sbreak) _ _ _ _ |- _ =>
      destruct b; inv Hx end.
    + congruence.
    + left. destruct (Z.eqb_spec (N - k) 0); cbn in Eb; try discriminate Eb.
      repeat split; auto; lia.
Qed.

Lemma loop_inv : forall e le mk S t le' m' out,
  exec_stmt function_entry2 G e le mk S t le' m' out ->
  e = empty_env -> S = dma_loop ->
  forall k, INV k le mk -> out = Out_normal /\ INV N le' m'.
Proof using All.
  intros e le mk S t le' m' out H. rewrite dma_loop_shape.
  induction H; intros Ee ES; try discriminate ES; injection ES as -> ->; subst e; intros k I.
  - match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      destruct (s1_cases _ _ _ _ _ _ _ I Hx) as [(-> & -> & -> & ->) | (-> & _)] end;
    match goal with Hb : out_break_or_return _ _ |- _ => inv Hb end.
    split; [ reflexivity | exact I ].
  - match goal with Hx : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv Hx end.
    match goal with Hb : out_break_or_return _ _ |- _ => inv Hb end.
  - match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      destruct (s1_cases _ _ _ _ _ _ _ I Hx) as [(_ & -> & _) | (-> & k' & _ & I')] end.
    + match goal with Hb : out_normal_or_continue _ |- _ => inv Hb end.
    + match goal with Hx : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv Hx end.
      match goal with IH : empty_env = empty_env -> _ |- _ => exact (IH eq_refl eq_refl k' I') end.
Qed.
End LOOP.

Lemma sub_pp : forall b o1 o2 m,
  sem_binary_operation (genv_cenv G) Osub (Vptr b o1) (tptr tuchar) (Vptr b o2) (tptr tuchar) m
  = Some (Vint (Ptrofs.to_int (Ptrofs.divs (Ptrofs.sub o1 o2) (Ptrofs.repr 1)))).
Proof. intros. cbn. destruct (eq_block b b); [ reflexivity | congruence ]. Qed.

(* dma_read's content: the destination's n bytes hold gMarioAnims' bytes *)
Theorem dma_read_content : forall m bd od s e t m' vres,
  eval_funcall function_entry2 G m (Internal memory.f_dma_read)
    [Vptr bd od; Vptr bga s; Vptr bga e] t m' vres ->
  bd <> bga -> bd <> biom -> bd <> bmq -> bd <> brm ->
  Ptrofs.unsigned od + Int.unsigned (dma_n s e) < Ptrofs.modulus ->
  Ptrofs.unsigned s + Int.unsigned (dma_n s e) < Ptrofs.modulus ->
  Mem.range_perm m bd (Ptrofs.unsigned od) (Ptrofs.unsigned od + Int.unsigned (dma_n s e)) Cur Readable ->
  vres = Vundef /\ Mem.unchanged_on (dfoot bd od (Int.unsigned (dma_n s e))) m m' /\ same_perms m m'
  /\ forall i, 0 <= i < Int.unsigned (dma_n s e) ->
       Mem.perm m bga (Ptrofs.unsigned s + i) Cur Readable ->
       cont m' bd (Ptrofs.unsigned od + i) = cont m bga (Ptrofs.unsigned s + i).
Proof.
  intros m bd od s e t m' vres Hevf N1 N2 N3 N4 Bd Bs Pd.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    change (fn_vars memory.f_dma_read) with (@nil (ident * type)) in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [fn_params memory.f_dma_read bind_parameter_temps] in Hb; injection Hb as <- end.
  match goal with Hfr : Mem.free_list _ _ = Some _ |- _ =>
    change (blocks_of_env G empty_env) with (@nil (block * Z * Z)) in Hfr; inv Hfr end.
  match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into Hbody end.
  rewrite dma_shape in Hbody.
  apply seq_inv in Hbody as (ta & lea & ma & tb & Hsz & Hbody); [ | reflexivity ].
  apply seq_inv in Hbody as (tc & lec & mc & td & Hiv & Hloop); [ | reflexivity ].
  (* size *)
  inv Hsz. unfold dma_size_e in *. cbn [memory.f_dma_read fn_body] in *.
  inv_ev.
  repeat match goal with H : PTree.get _ _ = Some _ |- _ => tgetH H; injection H as <- end.
  cbn [typeof] in *.
  match goal with H : sem_binary_operation _ Osub _ _ _ _ _ = Some _ |- _ =>
    rewrite sub_pp in H; injection H as <- end.
  match goal with H : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
    unfold sem_binary_operation, sem_add, sem_binarith, sem_cast, Archi.ptr64 in H; cbn in H;
    injection H as <- end.
  match goal with H : sem_unary_operation _ _ _ _ = Some _ |- _ => cbn in H; injection H as <- end.
  match goal with H : sem_binary_operation _ Oand _ _ _ _ _ = Some _ |- _ =>
    unfold sem_binary_operation, sem_and, sem_binarith, sem_cast, Archi.ptr64 in H; cbn in H;
    injection H as <- end.
  set (N := Int.unsigned (dma_n s e)) in *.
  (* osInvalDCache *)
  unfold dma_inval in Hiv. cbn [memory.f_dma_read fn_body] in Hiv.
  destruct (os_call2 memory._osInvalDCache "osInvalDCache"%string _ _ _ _ _ _ _ _ eq_refl os_inval_named Hiv eq_refl)
    as (sg & tyargs & tyres & cc & vargs & vres' & Hcl & Hel & Hx & -> & _).
  cbn in Hcl. injection Hcl as <- <- <-.
  repeat match goal with H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end.
  inv_ev.
  repeat match goal with H : PTree.get _ _ = Some _ |- _ => tgetH H; injection H as <- end.
  repeat match goal with Hcs : sem_cast _ _ _ _ = Some _ |- _ =>
    unfold sem_cast, Archi.ptr64 in Hcs; cbn in Hcs; injection Hcs as <- end.
  destruct Hfloor as (Hivs & _).
  destruct (Hivs _ _ _ _ _ _ _ Hx) as (bp & op & n & Ev & UO & SP & _ & _).
  injection Ev as <- <- En.
  assert (HN : 0 <= N <= Int.max_unsigned) by apply Int.unsigned_range_2.
  assert (I0 : INV ma bd od s N 0
                 (PTree.set memory._size (Vint (dma_n s e))
                   (PTree.set memory._srcEnd (Vptr bga e)
                     (PTree.set memory._srcStart (Vptr bga s)
                       (PTree.set memory._dest (Vptr bd od)
                         (PTree.set memory._size Vundef
                           (PTree.set memory._copySize Vundef
                             (PTree.set memory._t'1 Vundef (PTree.empty val)))))))) mc).
  { split; [ lia | ].
    split; [ rewrite PTree.gss, Z.sub_0_r; unfold N; rewrite Int.repr_unsigned; reflexivity | ].
    split; [ exists od; split; [ tget; reflexivity | lia ] | ].
    split; [ exists s; split; [ tget; reflexivity | lia ] | ].
    split.
    { eapply Mem.unchanged_on_implies; [ exact UO | ]. intros b z (D & _) _.
      subst n. exact D. }
    split; [ exact SP | ]. intros i Ri. lia. }
  destruct (loop_inv ma bd od s N N1 N2 N3 N4 HN Bd Bs Pd _ _ _ _ _ _ _ _ Hloop eq_refl eq_refl 0 I0)
    as (Eo & (_ & _ & _ & _ & UOf & SPf & CTf)).
  subst out.
  match goal with Ho : outcome_result_value _ _ _ _ |- _ => cbn in Ho end.
  split; [ assumption | split; [ exact UOf | split; [ exact SPf | exact CTf ] ] ].
Qed.
End DC.
