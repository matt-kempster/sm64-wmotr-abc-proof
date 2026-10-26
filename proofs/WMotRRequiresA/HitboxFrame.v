(* ====================================================================== *)
(* HitboxFrame (GOAL 2, 2026-10-25): the body half of NaSplit's row for   *)
(* mario_update_hitbox_and_cap_model, from the real mario.c bodies.       *)
(*                                                                        *)
(* ON THE SPINE: NaSplit's hitbox_row reads hitbox_frame; the world half *)
(* is HoleX.hx_fworld (ProRows' hole generalised to a set of global      *)
(* blocks plus two windows of Mario's object), fed by the ffw pins       *)
(* ff_Spl / ff_Spool / ff_Sar / ff_Sctl / ff_Cd.                          *)
(*                                                                        *)
(* 1. ucf_hole: update_and_return_cap_flags(m), m = &gMarioStates[0],     *)
(*    changes only m->flags / m->capTimer (bytes 4..7 and 182..183 of     *)
(*    Mario's block, inside ProRows' hole) and the cap music path's       *)
(*    globals (CapAudio.cap_ids).                                         *)
(* 2. hitbox_frame: the hitbox body changes, besides those, only          *)
(*    gBodyStates (the bodyState stores: modelState, handState, capState) *)
(*    and two cells of Mario's object: gfx.node.flags (bytes 2..3, the    *)
(*    GRAPH_RENDER_INVISIBLE blink) and hitboxHeight (bytes 508..511).    *)
(* 3. hitbox_hh: and after the body Mario's hitboxHeight is 100.0f or     *)
(*    160.0f (the store is on every path; the tail only writes            *)
(*    gBodyStates).  HH_coin restates it as CoinLink.MARIO_COIN2's Lha /  *)
(*    Fha / Hmario_height for Mario's object.                             *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool Lra.
From Coq Require Import Rdefinitions.
From Flocq Require Defs Binary.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario sound_init.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame RealFrameValue RealFrameLinked
  CensusV2 MtxfBody ObjExtBodies AudioBodies LinkedTwelve.
From SM64.Proofs.WMotRRequiresA Require Import BodyFrame FrameSplit LsContract CapAudio.
From SM64.Proofs Require AirborneSurface.
From SM64.Proofs.WMotRRequiresA Require ProRows.
From SM64.Proofs.WMotRRequiresA Require FfWorld.

Import ListNotations.

Module SI := sound_init.

(* the hole of Mario's block a call may write (ProRows.PH's) *)
Definition mhole (z : Z) : Prop := 4 <= z < 8 \/ 174 <= z < 184.

Definition mh_in (d s : Z) : bool :=
  ((4 <=? d) && (d + s <=? 8)) || ((174 <=? d) && (d + s <=? 184)).

Lemma mh_in_spec : forall d s, mh_in d s = true ->
  (4 <= d /\ d + s <= 8) \/ (174 <= d /\ d + s <= 184).
Proof.
  intros d s H. unfold mh_in in H. apply orb_true_iff in H as [H | H];
    apply andb_true_iff in H as [H1 H2]; apply Z.leb_le in H1; apply Z.leb_le in H2; [left | right]; lia.
Qed.

(* `m->f = ...`, f a by-value field of the hole *)
Definition mf_ok (f : ident) (ty : type) : bool :=
  match access_mode ty with
  | By_value ch =>
      match mario_fo mario._MarioState f with
      | Some (d, Full) => mh_in d (size_chunk ch)
      | _ => false
      end
  | _ => false
  end.

Lemma mf_ok_spec : forall f ty, mf_ok f ty = true ->
  exists ch d, access_mode ty = By_value ch /\ mario_fo mario._MarioState f = Some (d, Full)
    /\ mh_in d (size_chunk ch) = true.
Proof.
  intros f ty H. unfold mf_ok in H.
  destruct (access_mode ty) as [ch | | |] eqn:E1; [| exact (False_ind _ (diff_false_true H))
    | exact (False_ind _ (diff_false_true H)) | exact (False_ind _ (diff_false_true H))].
  destruct (mario_fo mario._MarioState f) as [[d bf] |] eqn:E2;
    [| exact (False_ind _ (diff_false_true H))].
  destruct bf as [| sz sg pos w]; [| exact (False_ind _ (diff_false_true H))].
  exists ch, d. split; [reflexivity |]. split; [reflexivity | exact H].
Qed.

Definition mf_store_ok (lv : expr) : bool :=
  match lv with
  | Efield (Ederef (Etempvar x _) (Tstruct sid (mk_attr false None))) f ty =>
      Pos.eqb x mario._m && Pos.eqb sid mario._MarioState && mf_ok f ty
  | _ => false
  end.

Definition cap_calls : list ident := [SI._stop_cap_music; SI._fadeout_cap_music].

Definition ucf_call_ok (optid : option ident) (a : expr) (al : list expr) : bool :=
  gcall_ok cap_calls a al && match optid with None => true | Some _ => false end.

Definition ucf_set_ok (id : ident) (_ : expr) : bool := negb (Pos.eqb id mario._m).

Lemma ucf_chk : lw_chk ucf_set_ok (fun lv _ => mf_store_ok lv) ucf_call_ok
                  (fn_body mario.f_update_and_return_cap_flags) = true.
Proof. vm_compute. reflexivity. Qed.

Section HB.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hlsf : ls_frame lp.
  Variable bm : block.

  Notation ge := (lp_ge lp).

  (* the cells ucf may change: cap_ids' blocks and Mario's hole *)
  Definition K1 (b : block) (z : Z) : Prop := ~ gblk ge cap_ids b /\ ~ (b = bm /\ mhole z).

  Lemma mf_step : forall v lv rhs le m1 t le' m2 out,
    mf_store_ok lv = true -> le ! mario._m = Some v -> marg_ok bm [v] ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out ->
    Q2 (fun b z => ~ (b = bm /\ mhole z)) m1 m2.
  Proof.
    intros v lv rhs le m1 t le' m2 out Hok Hle Hmarg Hx.
    unfold mf_store_ok in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    repeat rewrite andb_true_iff in Hok. destruct Hok as ((E1 & E2) & E3).
    apply Pos.eqb_eq in E1, E2. subst.
    destruct (mf_ok_spec _ _ E3) as (ch & d & Eam & Efo & Hh).
    apply mh_in_spec in Hh.
    inv Hx.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L1 eq_refl Efo)
      as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as ->.
    destruct Hmarg as [-> ->].
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      match goal with Hm : access_mode (typeof _) = _ |- _ =>
        cbn [typeof] in Hm; rewrite Eam in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as Hch; subst chunk end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => rename Hs into Hst end.
    cbn [fst Mem.storev] in Hst. rewrite Ptrofs.add_zero_l in Hst.
    rewrite Ptrofs.unsigned_repr in Hst
      by (change Ptrofs.max_unsigned with 4294967295; pose proof (size_chunk_pos ch) as Hsz; clear - Hh Hsz; lia).
    apply (st_q2 _ _ _ _ _ _ _ Hst).
    intros j Hj Hn. apply Hn. split; [reflexivity |]. unfold mhole. clear - Hj Hh. lia.
  Qed.

  Lemma ucf_call : forall optid a al le m t le' m' out,
    ucf_call_ok optid a al = true ->
    exec_stmt function_entry2 ge empty_env le m (Scall optid a al) t le' m' out ->
    Q2 (ak lp cap_ids) m m' /\ le' = le.
  Proof.
    intros optid a al le m t le' m' out Hok Hx.
    unfold ucf_call_ok in Hok. apply andb_prop in Hok as [Hc Ho].
    destruct optid as [ti|]; [discriminate Ho |].
    assert (Hids : forall g, mem_id g cap_calls = true -> af_pres lp cap_ids g).
    { intros g Hg. cbn [mem_id existsb cap_calls] in Hg.
      apply orb_true_iff in Hg as [Hg | Hg]; [apply Pos.eqb_eq in Hg; subst g;
        exact (af_stop_cap_music lp H12 Hlsf) |].
      apply orb_true_iff in Hg as [Hg | Hg]; [apply Pos.eqb_eq in Hg; subst g;
        exact (af_fadeout_cap_music lp H12) | discriminate Hg]. }
    assert (HP : au_P lp nil le) by (intros t0 g b o Ht; discriminate Ht).
    assert (Hok : au_call_ok nil cap_calls None a al = true)
      by (unfold au_call_ok; rewrite Hc; reflexivity).
    destruct (af_call lp cap_ids nil cap_calls Hids None a al le m t le' m' out Hok HP Hx) as (Hq & _).
    split; [exact Hq |]. inv Hx. reflexivity.
  Qed.

  (* 1. the field-level frame of update_and_return_cap_flags *)
  Theorem ucf_hole : forall m v t m' vres, marg_ok bm [v] ->
    eval_funcall function_entry2 ge m (Internal mario.f_update_and_return_cap_flags) [v] t m' vres ->
    Q2 K1 m m'.
  Proof.
    intros m v t m' vres Hmarg Hev.
    refine (lw_body_frame ge (Q2 K1 m) mario.f_update_and_return_cap_flags
              (fun le => le ! mario._m = Some v) ucf_set_ok (fun lv _ => mf_store_ok lv) ucf_call_ok
              eq_refl ucf_chk _ _ _ m [v] t m' vres Hev _ (Q2_refl _ m)).
    - intros id a le m1 v1 Hs Hp _ _. unfold ucf_set_ok in Hs.
      rewrite PTree.gso; [exact Hp |]. intros E. rewrite E, Pos.eqb_refl in Hs. discriminate Hs.
    - intros lv rhs le m1 t1 le1 m2 out Hs Hp Hx HQ1.
      apply (Q2_trans _ _ _ _ HQ1).
      apply (Q2_mono (fun b z => ~ (b = bm /\ mhole z))); [intros b z (_ & H); exact H |].
      exact (mf_step v lv rhs le m1 t1 le1 m2 out Hs Hp Hmarg Hx).
    - intros optid a al le m1 t1 le1 m2 out Hs Hp Hx HQ1.
      destruct (ucf_call optid a al le m1 t1 le1 m2 out Hs Hx) as (Hq & ->).
      split; [| exact Hp].
      apply (Q2_trans _ _ _ _ HQ1).
      apply (Q2_mono (ak lp cap_ids)); [intros b z (H & _); exact H | exact Hq].
    - intros le1 Hb. cbn in Hb. injection Hb as <-. apply PTree.gss.
  Qed.
End HB.

(* ---------------------------------------------------------------------- *)
(* 2. the hitbox body.  Its temps: class 1 holds Mario's state pointer    *)
(*    (m, and gMarioState's two reads), class 2 Mario's object            *)
(*    (m->marioObj, gMarioState->marioObj), class 3 m->marioBodyState.    *)
(* ---------------------------------------------------------------------- *)
Definition SM : list ident := [mario._m; mario._t'12; mario._t'14].
Definition OT2 : list ident := [mario._t'10; mario._t'11; mario._t'13; mario._t'15].

Definition cls (x : ident) : nat :=
  if existsb (Pos.eqb x) SM then 1%nat
  else if existsb (Pos.eqb x) OT2 then 2%nat
  else if Pos.eqb x mario._bodyState then 3%nat else 0%nat.

Lemma cls_m : cls mario._m = 1%nat.
Proof. vm_compute. reflexivity. Qed.
Lemma cls_bs : cls mario._bodyState = 3%nat.
Proof. vm_compute. reflexivity. Qed.

Definition gms_src (a : expr) : bool :=
  match a with
  | Evar g (Tpointer _ _) => Pos.eqb g mario._gMarioState
  | _ => false
  end.

(* p->f, p a class-1 temp *)
Definition sm_fld (f : ident) (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar x (Tpointer (Tstruct s1 (mk_attr false None)) (mk_attr false None)))
                   (Tstruct s2 (mk_attr false None))) f' (Tpointer _ _) =>
      Nat.eqb (cls x) 1 && Pos.eqb s1 mario._MarioState && Pos.eqb s2 mario._MarioState
      && Pos.eqb f' f
  | _ => false
  end.

Definition hb_set_ok (id : ident) (a : expr) : bool :=
  match cls id with
  | 1%nat => negb (Pos.eqb id mario._m) && gms_src a
  | 2%nat => sm_fld mario._marioObj a
  | 3%nat => sm_fld mario._marioBodyState a
  | _ => true
  end.

(* bodyState->f = ... *)
Definition bs_st (lv : expr) : bool :=
  match lv with
  | Efield (Ederef (Etempvar x _) _) _ _ => Pos.eqb x mario._bodyState
  | _ => false
  end.

(* o->hitboxHeight = ..., o a class-2 temp *)
Definition hh_st (lv : expr) : bool :=
  match lv with
  | Efield (Ederef (Etempvar x _) (Tstruct s (mk_attr false None))) f (Tfloat Ctypes.F32 _) =>
      Nat.eqb (cls x) 2 && Pos.eqb s mario._Object && Pos.eqb f mario._hitboxHeight
  | _ => false
  end.

(* o->header.gfx.node.flags = ..., o a class-2 temp *)
Definition nf_st (lv : expr) : bool :=
  match lv with
  | Efield (Efield (Efield (Efield (Ederef (Etempvar x _) (Tstruct s1 (mk_attr false None))) f1
                                   (Tstruct s2 (mk_attr false None))) f2
                           (Tstruct s3 (mk_attr false None))) f3
                   (Tstruct s4 (mk_attr false None))) f4 (Tint I16 Signed _) =>
      Nat.eqb (cls x) 2 && Pos.eqb s1 mario._Object && Pos.eqb f1 mario._header
      && Pos.eqb s2 mario._ObjectNode && Pos.eqb f2 mario._gfx
      && Pos.eqb s3 mario._GraphNodeObject && Pos.eqb f3 mario._node
      && Pos.eqb s4 mario._GraphNode && Pos.eqb f4 mario._flags
  | _ => false
  end.

Definition hb_store_ok (lv _ : expr) : bool := bs_st lv || hh_st lv || nf_st lv.

(* t = update_and_return_cap_flags(p), t unclassed, p class 1 *)
Definition hb_call_ok (optid : option ident) (a : expr) (al : list expr) : bool :=
  match optid, a, al with
  | Some t, Evar f (Tfunction _ _ _), Etempvar x (Tpointer _ _) :: nil =>
      Pos.eqb f mario._update_and_return_cap_flags && Nat.eqb (cls t) 0 && Nat.eqb (cls x) 1
  | _, _, _ => false
  end.

Lemma hb_chk : lw_chk hb_set_ok hb_store_ok hb_call_ok
                 (fn_body mario.f_mario_update_hitbox_and_cap_model) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma hb_mobj_fo : mario_fo mario._MarioState mario._marioObj = Some (136, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma hb_body_fo : mario_fo mario._MarioState mario._marioBodyState = Some (152, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma hh_fo : mario_fo mario._Object mario._hitboxHeight = Some (508, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma hb_hdr_fo : mario_fo mario._Object mario._header = Some (0, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma hb_gfx_fo : mario_fo mario._ObjectNode mario._gfx = Some (0, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma hb_node_fo : mario_fo mario._GraphNodeObject mario._node = Some (0, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma hb_flags_fo : mario_fo mario._GraphNode mario._flags = Some (2, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma dm_ucf : (prog_defmap mario.prog) ! mario._update_and_return_cap_flags
  = Some (Gfun (Internal mario.f_update_and_return_cap_flags)).
Proof. vm_compute. reflexivity. Qed.

Lemma gms_not_cap : existsb (Pos.eqb mario._gMarioState) cap_ids = false.
Proof. vm_compute. reflexivity. Qed.

Lemma hb_add_u : forall oo d, 0 <= d -> Ptrofs.unsigned oo + d <= Ptrofs.max_unsigned ->
  Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr d)) = Ptrofs.unsigned oo + d.
Proof.
  intros oo d H0 H1. pose proof (Ptrofs.unsigned_range oo) as Ro.
  unfold Ptrofs.add. rewrite (Ptrofs.unsigned_repr d) by lia. apply Ptrofs.unsigned_repr. lia.
Qed.

(* a pointer value that, if it is a pointer, is (b, o) *)
Definition pt_is (b : block) (o : ptrofs) (p : val) : Prop :=
  forall b' o', p = Vptr b' o' -> b' = b /\ o' = o.

(* statements with no break / continue / return / loop / switch end normally *)
Fixpoint nb (s : statement) : bool :=
  match s with
  | Sskip | Sassign _ _ | Sset _ _ | Scall _ _ _ | Sbuiltin _ _ _ _ => true
  | Ssequence a b => nb a && nb b
  | Sifthenelse _ a b => nb a && nb b
  | _ => false
  end.

Lemma nb_normal : forall ge e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> nb s = true -> out = Out_normal.
Proof.
  intros ge e le m s t le' m' out H. induction H; intros Hn; cbn [nb] in Hn;
    try discriminate Hn; try reflexivity.
  - apply andb_prop in Hn as [_ B2]. exact (IHexec_stmt2 B2).
  - apply andb_prop in Hn as [B1 _]. exfalso. exact (H0 (IHexec_stmt B1)).
  - apply andb_prop in Hn as [B1 B2]. apply IHexec_stmt. destruct b; assumption.
Qed.

Lemma seq_split : forall ge e le m s1 s2 t le' m' out, nb s1 = true ->
  exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out ->
  exists t1 le1 m1 t2, exec_stmt function_entry2 ge e le m s1 t1 le1 m1 Out_normal
    /\ exec_stmt function_entry2 ge e le1 m1 s2 t2 le' m' out.
Proof.
  intros ge e le m s1 s2 t le' m' out Hn H. inv H.
  - do 4 eexists. split; eassumption.
  - match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ ?o, Hne : ?o <> Out_normal |- _ =>
      exfalso; exact (Hne (nb_normal _ _ _ _ _ _ _ _ _ H1 Hn)) end.
Qed.

Lemma seq_split2 : forall ge e le m s1 s2 t le' m' out,
  exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out -> nb s1 = true ->
  exists t1 le1 m1 t2, exec_stmt function_entry2 ge e le m s1 t1 le1 m1 Out_normal
    /\ exec_stmt function_entry2 ge e le1 m1 s2 t2 le' m' out.
Proof. intros. eapply seq_split; eassumption. Qed.

(* the two values the body writes into Mario's hitboxHeight *)
Definition f100 : float32 := Float32.of_bits (Int.repr 1120403456).   (* 0x42C80000 *)
Definition f160 : float32 := Float32.of_bits (Int.repr 1126170624).   (* 0x43200000 *)

Lemma f100_val : Binary.B2R 24 128 f100 = 100%R.
Proof. unfold f100. vm_compute (Float32.of_bits _). unfold Binary.B2R, Defs.F2R. simpl. lra. Qed.
Lemma f160_val : Binary.B2R 24 128 f160 = 160%R.
Proof. unfold f160. vm_compute (Float32.of_bits _). unfold Binary.B2R, Defs.F2R. simpl. lra. Qed.
Lemma f100_fin : Binary.is_finite 24 128 f100 = true.
Proof. vm_compute. reflexivity. Qed.
Lemma f160_fin : Binary.is_finite 24 128 f160 = true.
Proof. vm_compute. reflexivity. Qed.

Section HF.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hlsf : ls_frame lp.
  Variables bm bbs bo bg : block.
  Variable oo : ptrofs.
  Variable m0 : mem.

  Notation ge := (lp_ge lp).

  (* the entry memory's pointers: gMarioState = &Mario, m->marioObj =
     Mario's object, m->marioBodyState into gBodyStates; the blocks apart *)
  Hypothesis Hbg : Genv.find_symbol ge mario._gMarioState = Some bg.
  Hypothesis HLG : forall b o, Mem.load Mint32 m0 bg 0 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero.
  Hypothesis HLO : forall b o, Mem.load Mint32 m0 bm 136 = Some (Vptr b o) -> b = bo /\ o = oo.
  Hypothesis HLB : forall b o, Mem.load Mint32 m0 bm 152 = Some (Vptr b o) -> b = bbs.
  Hypothesis NGm : ~ gblk ge cap_ids bm.
  Hypothesis Nmb : bm <> bbs.
  Hypothesis Nmo : bm <> bo.
  Hypothesis Ngb : bg <> bbs.
  Hypothesis Ngo : bg <> bo.
  Hypothesis Hoo : Ptrofs.unsigned oo + 512 <= Ptrofs.modulus.
  Hypothesis Nbo : bbs <> bo.

  (* the cells the hitbox body may change, besides K1's *)
  Definition K2 (b : block) (z : Z) : Prop :=
    K1 lp bm b z /\ b <> bbs
    /\ ~ (b = bo /\ (Ptrofs.unsigned oo + 2 <= z < Ptrofs.unsigned oo + 4
                     \/ Ptrofs.unsigned oo + 508 <= z < Ptrofs.unsigned oo + 512)).

  Definition hb_inv (k : nat) (p : val) : Prop :=
    match k with
    | 1%nat => pt_is bm Ptrofs.zero p
    | 2%nat => pt_is bo oo p
    | 3%nat => forall b o, p = Vptr b o -> b = bbs
    | _ => True
    end.

  Definition hb_P (le : temp_env) : Prop := forall x p, le ! x = Some p -> hb_inv (cls x) p.

  Lemma ngb_cap : ~ gblk ge cap_ids bg.
  Proof.
    intros (g & Hin & Hg).
    assert (g = mario._gMarioState) by (eapply Genv.genv_vars_inj; [exact Hg | exact Hbg]). subst g.
    assert (T : existsb (Pos.eqb mario._gMarioState) cap_ids = true)
      by (apply existsb_exists; exists mario._gMarioState; split; [exact Hin | apply Pos.eqb_refl]).
    rewrite gms_not_cap in T. discriminate T.
  Qed.

  Lemma hb_keep_m : forall i, 136 <= i < 156 -> K2 bm i.
  Proof.
    intros i Hi. split; [split; [exact NGm | intros (_ & H); unfold mhole in H; lia] |].
    split; [exact Nmb | intros (E & _); exact (Nmo E)].
  Qed.

  Lemma hb_keep_g : forall i, 0 <= i < 4 -> K2 bg i.
  Proof.
    intros i Hi. split; [split; [exact ngb_cap | intros (_ & H); unfold mhole in H; lia] |].
    split; [exact Ngb | intros (E & _); exact (Ngo E)].
  Qed.

  Lemma sm_fld_val : forall f d le m1 a v1, sm_fld f a = true -> hb_P le ->
    mario_fo mario._MarioState f = Some (d, Full) -> 0 <= d < 1024 ->
    eval_expr ge empty_env le m1 a v1 -> Mem.load Mint32 m1 bm d = Some v1.
  Proof.
    intros f d le m1 a v1 Hs HP Hfo Hd Ea. unfold sm_fld in Hs.
    repeat match type of Hs with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hs
    end.
    repeat rewrite andb_true_iff in Hs. destruct Hs as (((E1 & E2) & E3) & E4).
    apply Nat.eqb_eq in E1. apply Pos.eqb_eq in E2, E3, E4. subst.
    pose proof Ea as Ea'. apply eval_expr_Efield_load in Ea' as (loc & ofs & bf & L & _).
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L eq_refl Hfo)
      as (o0 & E0 & _ & _).
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    pose proof (HP _ _ L0) as Hi. rewrite E1 in Hi. cbn [hb_inv] in Hi.
    destruct (Hi _ _ eq_refl) as (-> & ->).
    match type of Ea with eval_expr _ _ _ _ (Efield _ _ ?ty) _ =>
      destruct (ProRows.ev_fld lp H12 bm _ le m1 (Vptr bm Ptrofs.zero) f ty Mint32 d v1 L0
                  (conj eq_refl eq_refl) Hfo Hd eq_refl Ea) as (_ & Hl) end.
    exact Hl.
  Qed.

  Lemma hb_set : forall id a le m1 v1,
    hb_set_ok id a = true -> hb_P le -> Q2 K2 m0 m1 ->
    eval_expr ge empty_env le m1 a v1 -> hb_P (PTree.set id v1 le).
  Proof.
    intros id a le m1 v1 Hs HP HQ Ea x p Hx.
    destruct (peq x id) as [-> | Nx]; [| rewrite PTree.gso in Hx by exact Nx; exact (HP x p Hx)].
    rewrite PTree.gss in Hx. injection Hx as <-.
    unfold hb_set_ok in Hs. revert Hs.
    destruct (cls id) as [| [| [| [| k]]]] eqn:Ec; intros Hs; cbn [hb_inv]; try exact I.
    - apply andb_prop in Hs as (_ & Hg). unfold gms_src in Hg.
      repeat match type of Hg with
      | match ?x with _ => _ end = true => destruct x; try discriminate Hg
      end.
      apply Pos.eqb_eq in Hg. subst.
      match type of Ea with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
        destruct (ProRows.ev_gvar _ _ _ _ ty Mint32 _ eq_refl Ea) as (b & Hsy & Hl) end.
      assert (b = bg) by congruence. subst b.
      rewrite (Q2_load _ _ _ HQ) in Hl by (intros i Hi; apply hb_keep_g; cbn [size_chunk] in Hi; lia).
      intros b o ->. exact (HLG _ _ Hl).
    - pose proof (sm_fld_val _ _ _ _ _ _ Hs HP hb_mobj_fo ltac:(lia) Ea) as Hl.
      rewrite (Q2_load _ _ _ HQ) in Hl by (intros i Hi; apply hb_keep_m; cbn [size_chunk] in Hi; lia).
      intros b o ->. exact (HLO _ _ Hl).
    - pose proof (sm_fld_val _ _ _ _ _ _ Hs HP hb_body_fo ltac:(lia) Ea) as Hl.
      rewrite (Q2_load _ _ _ HQ) in Hl by (intros i Hi; apply hb_keep_m; cbn [size_chunk] in Hi; lia).
      intros b o ->. exact (HLB _ _ Hl).
  Qed.

  Lemma bs_step0 : forall lv rhs le m1 t le' m2 out,
    bs_st lv = true -> hb_P le ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out ->
    Q2 (fun b _ => b <> bbs) m1 m2.
  Proof.
    intros lv rhs le m1 t le' m2 out Hok HP Hx.
    unfold bs_st in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    apply Pos.eqb_eq in Hok. subst.
    inv Hx.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    apply eval_lvalue_Efield_inv in L1 as (o0 & sid & att & co & delta & Hb & _ & _ & Hcase).
    match type of Hb with eval_expr _ _ _ _ ?a0 _ =>
      assert (Am : access_mode (typeof a0) = By_copy)
        by (destruct Hcase as [(Ht & _) | (Ht & _)]; rewrite Ht; reflexivity) end.
    destruct (ex_agg lp _ _ _ _ _ Hb (or_intror Am) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    pose proof (HP _ _ L0) as Hi. rewrite cls_bs in Hi. cbn [hb_inv] in Hi.
    pose proof (Hi _ _ eq_refl) as ->.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => apply (al_q2 _ _ _ _ _ _ _ _ _ Ha) end.
    intros j H. exact (H eq_refl).
  Qed.

  Lemma bs_step : forall lv rhs le m1 t le' m2 out,
    bs_st lv = true -> hb_P le ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out -> Q2 K2 m1 m2.
  Proof.
    intros lv rhs le m1 t le' m2 out Hok HP Hx.
    apply (Q2_mono (fun b _ => b <> bbs)); [intros b z (_ & H & _); exact H |].
    exact (bs_step0 lv rhs le m1 t le' m2 out Hok HP Hx).
  Qed.

  Lemma hh_step : forall lv rhs le m1 t le' m2 out,
    hh_st lv = true -> hb_P le ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out -> Q2 K2 m1 m2.
  Proof.
    intros lv rhs le m1 t le' m2 out Hok HP Hx.
    unfold hh_st in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    repeat rewrite andb_true_iff in Hok. destruct Hok as ((E1 & E2) & E3).
    apply Nat.eqb_eq in E1. apply Pos.eqb_eq in E2, E3. subst.
    inv Hx.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L1 eq_refl hh_fo)
      as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    pose proof (HP _ _ L0) as Hi. rewrite E1 in Hi. cbn [hb_inv] in Hi.
    destruct (Hi _ _ eq_refl) as (-> & ->).
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => rename Hs into Hst end.
    cbn [fst Mem.storev] in Hst.
    rewrite hb_add_u in Hst by (try unfold Ptrofs.max_unsigned; lia).
    apply (st_q2 _ _ _ _ _ _ _ Hst).
    intros j Hj (_ & _ & Hn). apply Hn. split; [reflexivity |]. right. cbn [size_chunk] in Hj. lia.
  Qed.

  Lemma nf_step : forall lv rhs le m1 t le' m2 out,
    nf_st lv = true -> hb_P le ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out -> Q2 K2 m1 m2.
  Proof.
    intros lv rhs le m1 t le' m2 out Hok HP Hx.
    unfold nf_st in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    repeat match goal with H : _ && _ = true |- _ => apply andb_true_iff in H as (? & ?) end.
    repeat match goal with H : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in H; subst end.
    match goal with H : Nat.eqb (cls _) 2 = true |- _ => apply Nat.eqb_eq in H; rename H into E1 end.
    inv Hx.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ mario._flags _) _ _ _ |- _ => rename L into L4 end.
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L4 eq_refl hb_flags_fo)
      as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf3 & L3).
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L3 eq_refl hb_node_fo)
      as (o1 & E1' & -> & _).
    destruct (ex_agg lp _ _ _ _ _ E1' (or_intror eq_refl) I) as (bf2 & L2).
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L2 eq_refl hb_gfx_fo)
      as (o2 & E2 & -> & _).
    destruct (ex_agg lp _ _ _ _ _ E2 (or_intror eq_refl) I) as (bf1 & L1).
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L1 eq_refl hb_hdr_fo)
      as (o3 & E3 & -> & _).
    destruct (ex_agg lp _ _ _ _ _ E3 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    pose proof (HP _ _ L0) as Hi. rewrite E1 in Hi. cbn [hb_inv] in Hi.
    destruct (Hi _ _ eq_refl) as (-> & ->).
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => rename Hs into Hst end.
    cbn [fst Mem.storev] in Hst.
    change (Ptrofs.repr 0) with Ptrofs.zero in Hst. rewrite !Ptrofs.add_zero in Hst.
    rewrite hb_add_u in Hst by (try unfold Ptrofs.max_unsigned; lia).
    apply (st_q2 _ _ _ _ _ _ _ Hst).
    intros j Hj (_ & _ & Hn). apply Hn. split; [reflexivity |]. left. cbn [size_chunk] in Hj. lia.
  Qed.

  Lemma hb_store : forall lv rhs le m1 t le' m2 out,
    hb_store_ok lv rhs = true -> hb_P le ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out -> Q2 K2 m1 m2.
  Proof.
    intros lv rhs le m1 t le' m2 out Hs HP Hx. unfold hb_store_ok in Hs.
    apply orb_true_iff in Hs as [Hs | Hs]; [apply orb_true_iff in Hs as [Hs | Hs] |].
    - exact (bs_step lv rhs le m1 t le' m2 out Hs HP Hx).
    - exact (hh_step lv rhs le m1 t le' m2 out Hs HP Hx).
    - exact (nf_step lv rhs le m1 t le' m2 out Hs HP Hx).
  Qed.

  Lemma hb_callstep : forall optid a al le m1 t le' m2 out,
    hb_call_ok optid a al = true -> hb_P le ->
    exec_stmt function_entry2 ge empty_env le m1 (Scall optid a al) t le' m2 out ->
    Q2 K2 m1 m2 /\ hb_P le'.
  Proof.
    intros optid a al le m1 t le' m2 out Hok HP Hx.
    unfold hb_call_ok in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    repeat rewrite andb_true_iff in Hok. destruct Hok as ((Ef & Et) & Ex).
    apply Pos.eqb_eq in Ef. apply Nat.eqb_eq in Et, Ex. subst.
    inv Hx.
    match goal with Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hc; injection Hc as <- <- <- end.
    match goal with He : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (ProRows.ev_fun _ _ _ _ _ _ _ _ He) as (b & Hsy & ->) end.
    match goal with Hl : eval_exprlist _ _ _ _ _ _ _ |- _ => inv Hl end.
    match goal with Hl : eval_exprlist _ _ _ _ _ _ _ |- _ => inv Hl end.
    match goal with Ea : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Ea; rename Ea into Lx end.
    match goal with Hc : sem_cast _ _ _ _ = Some ?v2 |- _ =>
      assert (Hm2 : marg_ok bm [v2])
        by (destruct v2; cbn; try exact I;
            apply sem_cast_ptr_result_inv in Hc; subst;
            pose proof (HP _ _ Lx) as Hi; rewrite Ex in Hi; exact (Hi _ _ eq_refl)) end.
    match goal with Hff : Genv.find_funct _ _ = Some ?fd, Hev : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
      rename Hev into Hcall; rename Hff into Hff0 end.
    pose proof (AirborneSurface.resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_ucf
                  (ex_intro _ b (conj Hsy Hff0))) as Efd.
    rewrite Efd in Hcall.
    split.
    - apply (Q2_mono (K1 lp bm)); [intros b' z (H & _); exact H |].
      exact (ucf_hole lp H12 Hlsf bm _ _ _ _ _ Hm2 Hcall).
    - intros y p Hy. cbn [set_opttemp] in Hy.
      match type of Hy with (PTree.set ?t0 _ _) ! _ = _ =>
        destruct (peq y t0) as [-> | Ny] end.
      + rewrite PTree.gss in Hy. injection Hy as <-. rewrite Et. exact I.
      + rewrite PTree.gso in Hy by exact Ny. exact (HP _ _ Hy).
  Qed.

  (* 2. the hitbox body's frame *)
  Theorem hitbox_frame : forall v t m' vr, marg_ok bm [v] ->
    eval_funcall function_entry2 ge m0 (Internal mario.f_mario_update_hitbox_and_cap_model) [v] t m' vr ->
    Q2 K2 m0 m'.
  Proof.
    intros v t m' vr Hmarg Hev.
    refine (lw_body_frame ge (Q2 K2 m0) mario.f_mario_update_hitbox_and_cap_model hb_P
              hb_set_ok hb_store_ok hb_call_ok eq_refl hb_chk _ _ _ m0 [v] t m' vr Hev _ (Q2_refl _ m0)).
    - intros id a le m1 v1 Hs Hp HQ1 Ea. exact (hb_set id a le m1 v1 Hs Hp HQ1 Ea).
    - intros lv rhs le m1 t1 le1 m2 out Hs Hp Hx HQ1.
      exact (Q2_trans _ _ _ _ HQ1 (hb_store lv rhs le m1 t1 le1 m2 out Hs Hp Hx)).
    - intros optid a al le m1 t1 le1 m2 out Hs Hp Hx HQ1.
      destruct (hb_callstep optid a al le m1 t1 le1 m2 out Hs Hp Hx) as (Hq & Hp').
      exact (conj (Q2_trans _ _ _ _ HQ1 Hq) Hp').
    - intros le1 Hb.
      change (Some (PTree.set mario._m v (create_undef_temps (fn_temps mario.f_mario_update_hitbox_and_cap_model))) = Some le1) in Hb.
      injection Hb as <-.
      intros x p Hx. destruct (peq x mario._m) as [-> | Nx].
      + rewrite PTree.gss in Hx. injection Hx as <-. rewrite cls_m. intros b o ->. exact Hmarg.
      + rewrite PTree.gso in Hx by exact Nx.
        rewrite (cut_undef (fn_temps mario.f_mario_update_hitbox_and_cap_model) x p Hx).
        destruct (cls x) as [| [| [| [| k]]]]; cbn [hb_inv pt_is]; try exact I;
          intros b o E; discriminate E.
  Qed.

  (* 3. Mario's hitboxHeight after the body: 100.0f or 160.0f *)
  Definition HH (m : mem) : Prop :=
    exists x, Mem.load Mfloat32 m bo (Ptrofs.unsigned oo + 508) = Some (Vsingle x)
      /\ (x = f100 \/ x = f160).

  Lemma hb_init : forall v le1, marg_ok bm [v] ->
    bind_parameter_temps (fn_params mario.f_mario_update_hitbox_and_cap_model) [v]
      (create_undef_temps (fn_temps mario.f_mario_update_hitbox_and_cap_model)) = Some le1 ->
    hb_P le1.
  Proof.
    intros v le1 Hmarg Hb.
    change (Some (PTree.set mario._m v (create_undef_temps (fn_temps mario.f_mario_update_hitbox_and_cap_model))) = Some le1) in Hb.
    injection Hb as <-.
    intros x p Hx. destruct (peq x mario._m) as [-> | Nx].
    - rewrite PTree.gss in Hx. injection Hx as <-. rewrite cls_m. intros b o ->. exact Hmarg.
    - rewrite PTree.gso in Hx by exact Nx.
      rewrite (cut_undef (fn_temps mario.f_mario_update_hitbox_and_cap_model) x p Hx).
      destruct (cls x) as [| [| [| [| k]]]]; cbn [hb_inv pt_is]; try exact I;
        intros b o E; discriminate E.
  Qed.

  Lemma hb_walk : forall le m s t le' m' out,
    exec_stmt function_entry2 ge empty_env le m s t le' m' out ->
    lw_chk hb_set_ok hb_store_ok hb_call_ok s = true -> hb_P le -> Q2 K2 m0 m ->
    Q2 K2 m0 m' /\ hb_P le'.
  Proof.
    intros le m s t le' m' out Hx Hc HP HQ.
    refine (lw_walk ge empty_env (Q2 K2 m0) hb_P hb_set_ok hb_store_ok hb_call_ok _ _ _
              empty_env le m s t le' m' out Hx eq_refl Hc HP HQ).
    - intros id a le1 m1 v1 Hs Hp HQ1 Ea. exact (hb_set id a le1 m1 v1 Hs Hp HQ1 Ea).
    - intros lv rhs le1 m1 t1 le2 m2 out1 Hs Hp Hx1 HQ1.
      exact (Q2_trans _ _ _ _ HQ1 (hb_store lv rhs le1 m1 t1 le2 m2 out1 Hs Hp Hx1)).
    - intros optid a al le1 m1 t1 le2 m2 out1 Hs Hp Hx1 HQ1.
      destruct (hb_callstep optid a al le1 m1 t1 le2 m2 out1 Hs Hp Hx1) as (Hq & Hp').
      exact (conj (Q2_trans _ _ _ _ HQ1 Hq) Hp').
  Qed.

  Lemma hb_peel : forall le m s1 s2 t le' m' out,
    exec_stmt function_entry2 ge empty_env le m (Ssequence s1 s2) t le' m' out ->
    nb s1 = true -> lw_chk hb_set_ok hb_store_ok hb_call_ok s1 = true -> hb_P le -> Q2 K2 m0 m ->
    exists le1 m1 t2, hb_P le1 /\ Q2 K2 m0 m1
      /\ exec_stmt function_entry2 ge empty_env le1 m1 s2 t2 le' m' out.
  Proof.
    intros le m s1 s2 t le' m' out Hx Hn Hc HP HQ.
    destruct (seq_split _ _ _ _ _ _ _ _ _ _ Hn Hx) as (t1 & le1 & m1 & t2 & Hx1 & Hx2).
    destruct (hb_walk _ _ _ _ _ _ _ Hx1 Hc HP HQ) as (HQ1 & HP1).
    exists le1, m1, t2. exact (conj HP1 (conj HQ1 Hx2)).
  Qed.

  (* o->hitboxHeight = c *)
  Lemma hh_set_val : forall lv f le m1 t le' m2 out,
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv (Econst_single f tfloat)) t le' m2 out ->
    hh_st lv = true -> hb_P le ->
    Q2 K2 m1 m2 /\ le' = le
    /\ Mem.load Mfloat32 m2 bo (Ptrofs.unsigned oo + 508) = Some (Vsingle f).
  Proof.
    intros lv f le m1 t le' m2 out Hx Hok HP.
    split; [exact (hh_step _ _ _ _ _ _ _ _ Hok HP Hx) |].
    unfold hh_st in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    repeat rewrite andb_true_iff in Hok. destruct Hok as ((E1 & E2) & E3).
    apply Nat.eqb_eq in E1. apply Pos.eqb_eq in E2, E3. subst.
    inv Hx. split; [reflexivity |].
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L1 eq_refl hh_fo)
      as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    pose proof (HP _ _ L0) as Hi. rewrite E1 in Hi. cbn [hb_inv] in Hi.
    destruct (Hi _ _ eq_refl) as (-> & ->).
    match goal with Ec : eval_expr _ _ _ _ (Econst_single _ _) _ |- _ => inv Ec end;
      [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_single _ _) _ _ _ |- _ => inv Hl end].
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => cbn in Hc; injection Hc as <- end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => rename Hs into Hst end.
    cbn [fst Mem.storev] in Hst.
    rewrite hb_add_u in Hst by (try unfold Ptrofs.max_unsigned; lia).
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hst). reflexivity.
  Qed.

  (* the tail after the hitbox store only writes gBodyStates *)
  Lemma tail_walk : forall le m s t le' m' out,
    exec_stmt function_entry2 ge empty_env le m s t le' m' out ->
    lw_chk hb_set_ok (fun lv _ => bs_st lv) (fun _ _ _ => false) s = true ->
    hb_P le -> Q2 K2 m0 m /\ HH m -> Q2 K2 m0 m' /\ HH m'.
  Proof.
    intros le m s t le' m' out Hx Hc HP HQ.
    refine (proj1 (lw_walk ge empty_env (fun m => Q2 K2 m0 m /\ HH m) hb_P hb_set_ok
              (fun lv _ => bs_st lv) (fun _ _ _ => false) _ _ _
              empty_env le m s t le' m' out Hx eq_refl Hc HP HQ)).
    - intros id a le1 m1 v1 Hs Hp (HQ1 & _) Ea. exact (hb_set id a le1 m1 v1 Hs Hp HQ1 Ea).
    - intros lv rhs le1 m1 t1 le2 m2 out1 Hs Hp Hx1 (HQ1 & x & Hl & Hx').
      pose proof (bs_step0 lv rhs le1 m1 t1 le2 m2 out1 Hs Hp Hx1) as Hq.
      split.
      + apply (Q2_trans _ _ _ _ HQ1).
        apply (Q2_mono (fun b _ => b <> bbs)); [intros b z (_ & H & _); exact H | exact Hq].
      + exists x. split; [| exact Hx'].
        rewrite (Q2_load _ _ _ Hq); [exact Hl |].
        intros i _ E. exact (Nbo (eq_sym E)).
    - intros optid a al le1 m1 t1 le2 m2 out1 Hs. discriminate Hs.
  Qed.

  Ltac peel :=
    match goal with
    | HP : hb_P ?le, HQ : Q2 K2 m0 ?m,
      Hx : exec_stmt _ _ _ ?le ?m (Ssequence _ _) _ _ _ _ |- _ =>
        let le1 := fresh "le" in let m1 := fresh "m" in let t2 := fresh "t" in
        let HP1 := fresh "HP" in let HQ1 := fresh "HQ" in let Hx1 := fresh "Hx" in
        destruct (hb_peel _ _ _ _ _ _ _ _ Hx ltac:(reflexivity) ltac:(vm_compute; reflexivity) HP HQ)
          as (le1 & m1 & t2 & HP1 & HQ1 & Hx1);
        clear HP HQ Hx
    end.

  (* the hitbox body's frame, and Mario's hitboxHeight after it *)
  Theorem hitbox_hh : forall v t m' vr, marg_ok bm [v] ->
    eval_funcall function_entry2 ge m0 (Internal mario.f_mario_update_hitbox_and_cap_model) [v] t m' vr ->
    Q2 K2 m0 m' /\ HH m'.
  Proof.
    intros v t m' vr Hmarg Hev.
    destruct (ProRows.fc_entry ge m0 mario.f_mario_update_hitbox_and_cap_model [v] t m' vr eq_refl Hev) as (le & le' & t' & out & Hb & Hx).
    pose proof (hb_init v le Hmarg Hb) as HP. pose proof (Q2_refl K2 m0) as HQ.
    clear Hb Hev.
    cbn [fn_body mario.f_mario_update_hitbox_and_cap_model] in Hx.
    do 8 peel.
    match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      destruct (seq_split2 _ _ _ _ _ _ _ _ _ _ Hx ltac:(reflexivity)) as (tA & leA & mA & tB & Hh & Ht);
      clear Hx end.
    (* the hitbox statement: _t'9 := m->action; then one of the two stores *)
    peel.
    match goal with Hx : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv Hx end.
    match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
      destruct b; cbv iota in Hx end;
      peel;
      match goal with HP : hb_P ?l, Hx : exec_stmt _ _ _ ?l _ (Sassign _ _) _ _ _ _ |- _ =>
        destruct (hh_set_val _ _ _ _ _ _ _ _ Hx ltac:(vm_compute; reflexivity) HP) as (Hq & -> & Hl) end;
      match goal with HQ : Q2 K2 m0 ?mm, Hq : Q2 K2 ?mm _, Ht : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
        refine (tail_walk _ _ _ _ _ _ _ Ht ltac:(vm_compute; reflexivity) _ (conj (Q2_trans _ _ _ _ HQ Hq) _));
        [assumption | eexists; split; [exact Hl | unfold f100, f160; tauto]] end.
  Qed.

  (* HH in CoinLink.MARIO_COIN2's shape: Lha (ld at OFF_HEIGHT = 508), Fha
     and Hmario_height (0 <= R2 ha <= 160) for the object (bo, oo) *)
  Lemma HH_coin : forall m, HH m ->
    exists ha, Mem.loadv Mfloat32 m (Vptr bo (Ptrofs.add oo (Ptrofs.repr 508))) = Some (Vsingle ha)
      /\ Binary.is_finite 24 128 ha = true /\ (0 <= Binary.B2R 24 128 ha <= 160)%R.
  Proof.
    intros m (x & Hl & Hx). exists x. cbn [Mem.loadv].
    rewrite hb_add_u by (try unfold Ptrofs.max_unsigned; lia).
    split; [exact Hl |].
    destruct Hx as [-> | ->].
    - split; [exact f100_fin |]. rewrite f100_val. lra.
    - split; [exact f160_fin |]. rewrite f160_val. lra.
  Qed.
End HF.

(* ---------------------------------------------------------------------- *)
(* THE COIN-LINK PREMISES FROM THE FRAME WORLD (2026-10-26): ffw's ff_HH /  *)
(* ff_HD give, for Mario's object (m->marioObj), CoinLink.MARIO_COIN2's     *)
(* Lha / Fha / Hmario_height and Lda / Fda / Hmario_down (its ld is this    *)
(* Mem.loadv at Ptrofs.add o (Ptrofs.repr off), OFF_HEIGHT = 508,           *)
(* OFF_DOWN = 520).                                                         *)
(* ---------------------------------------------------------------------- *)
Lemma ffw_coin : forall (G : genv) bm m, FfWorld.ffw G bm m ->
  exists bo oo ha da,
    Mem.load Mint32 m bm FfWorld.FFW_OBJ = Some (Vptr bo oo)
    /\ Mem.loadv Mfloat32 m (Vptr bo (Ptrofs.add oo (Ptrofs.repr 508))) = Some (Vsingle ha)
    /\ Binary.is_finite 24 128 ha = true /\ (0 <= Binary.B2R 24 128 ha <= 160)%R
    /\ Mem.loadv Mfloat32 m (Vptr bo (Ptrofs.add oo (Ptrofs.repr 520))) = Some (Vsingle da)
    /\ Binary.is_finite 24 128 da = true /\ Binary.B2R 24 128 da = 0%R.
Proof.
  intros G bm m (_ & (d & F) & _).
  pose proof (FfWorld.ff_Soo _ _ _ _ F) as Soo. unfold FfWorld.SZ_OBJECT in Soo.
  destruct (FfWorld.ff_HH _ _ _ _ F) as (h & Lh & Eh).
  pose proof (FfWorld.ff_HD _ _ _ _ F) as Ld.
  exists (FfWorld.fw_bo d), (FfWorld.fw_oo d), h, FfWorld.FFW_F0.
  split; [exact (FfWorld.ff_Lo _ _ _ _ F) |].
  cbn [Mem.loadv].
  rewrite !hb_add_u by (try unfold Ptrofs.max_unsigned; lia).
  split; [exact Lh |].
  split; [destruct Eh as [-> | ->]; [exact f100_fin | exact f160_fin] |].
  split; [destruct Eh as [-> | ->]; [rewrite (f100_val : Binary.B2R 24 128 FfWorld.FFW_F100 = 100%R) | rewrite (f160_val : Binary.B2R 24 128 FfWorld.FFW_F160 = 160%R)]; lra |].
  split; [exact Ld |].
  split; [vm_compute; reflexivity | reflexivity].
Qed.
